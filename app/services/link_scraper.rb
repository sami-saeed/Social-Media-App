# app/services/link_scraper.rb
require "ferrum"
require "open-uri"
require "uri"

class LinkScraper
  DEFAULT_TIMEOUT = 25 # seconds

  def initialize(url, headless: true)
    @url = url
    @headless = headless
  end

  # Returns a Hash: { image_url: String|nil, text: String|nil, title: String|nil }
  def call
    validate_url!

    browser = Ferrum::Browser.new(
      headless: @headless,
      timeout: DEFAULT_TIMEOUT,
      # In containers you may need these flags:
      browser_options: {
        "no-sandbox" => nil,
        "disable-gpu" => nil,
        "disable-dev-shm-usage" => nil,
        "user-agent" => user_agent
      },
      process_timeout: 60
    )

    begin
      browser.goto(@url)

      # Let network settle
      safe_wait_network_idle(browser)

      # Dismiss common popups/overlays (cookie banners, lightboxes, etc.)
      dismiss_overlays(browser)

      # Prefer Open Graph tags (usually most reliable on social/public pages)
      og_image  = meta_content(browser, "[property='og:image']")
      og_desc   = meta_content(browser, "[property='og:description']")
      og_title  = meta_content(browser, "[property='og:title']")

      # Fallbacks if OG is missing
      main_image = og_image || largest_image(browser)
      main_text  = og_desc  || primary_text(browser)

      {
        image_url: absolutize(main_image),
        text:      sanitize_text(main_text),
        title:     sanitize_text(og_title) || browser.title
      }
    ensure
      browser&.quit
    end
  end

  private

  def validate_url!
    uri = URI.parse(@url)
    raise ArgumentError, "Unsupported URL" unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
  end

  def user_agent
    # A realistic UA reduces “bot” interstitials on many sites
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "\
    "(KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
  end

  def safe_wait_network_idle(browser)
    browser.network.wait_for_idle(timeout: 3)
  rescue StandardError
    # If network doesn’t go idle, proceed with DOM waits instead.
    nil
  end

  def meta_content(browser, selector)
    node = browser.at_css("meta#{selector}")
    node&.attribute("content")
  end

  def dismiss_overlays(browser)
    # Click common “close” controls if present
    try_click(browser, "[aria-label='Close']")
    try_click(browser, "[data-testid='cookie-policy-dialog'] button")
    try_click(browser, "button[aria-label='Dismiss']")
    try_click(browser, "div[role='dialog'] button")

    # As a last resort, remove obvious full-screen overlays
    browser.evaluate(<<~JS)
      (function() {
        const selectors = [
          "[role='dialog']",
          ".modal, .overlay, .backdrop",
          "#cookie-banner, .cookie, [id*='cookie']"
        ];
        selectors.forEach(sel => {
          document.querySelectorAll(sel).forEach(el => {
            if (el && el.parentElement) el.parentElement.removeChild(el);
          });
        });
      })();
    JS
  rescue StandardError
    # Swallow overlay errors gracefully
    nil
  end

  def try_click(browser, selector)
    node = browser.at_css(selector)
    node&.click
  rescue Ferrum::NodeNotFoundError, Ferrum::TimeoutError
    nil
  end

  # If no OG image, pick the largest visible image by natural area
  def largest_image(browser)
    browser.evaluate(<<~JS)
      (function(){
        const imgs = Array.from(document.images)
          .map(img => ({
            src: img.currentSrc || img.src || null,
            area: (img.naturalWidth || 0) * (img.naturalHeight || 0),
            w: img.naturalWidth || 0, h: img.naturalHeight || 0
          }))
          .filter(x => x.src)
          .sort((a,b) => b.area - a.area);
        return imgs.length ? imgs[0].src : null;
      })();
    JS
  rescue StandardError
    nil
  end

  # Try to grab meaningful text: article role, then main landmark, then longest paragraph
  def primary_text(browser)
    text = browser.evaluate(<<~JS)
      (function(){
        function getText(el){
          return el ? el.innerText || el.textContent || "" : "";
        }
        const bySelectors = [
          "[role='article']",
          "article",
          "main",
          "[data-testid='post_message']"
        ];
        for (const sel of bySelectors) {
          const el = document.querySelector(sel);
          const t = getText(el).trim();
          if (t && t.length > 20) return t;
        }

        // Longest paragraph fallback
        const ps = Array.from(document.querySelectorAll("p"))
          .map(p => (p.innerText || p.textContent || "").trim())
          .filter(Boolean)
          .sort((a,b) => b.length - a.length);
        return ps[0] || "";
      })();
    JS
    text
  rescue StandardError
    nil
  end

  def absolutize(src)
    return nil if src.nil? || src.empty?
    URI.join(@url, src).to_s
  rescue StandardError
    src # if join fails, return as-is
  end

  def sanitize_text(text)
    return nil unless text
    text = text.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
    text.strip.gsub(/\s+/, " ")
  end
end
