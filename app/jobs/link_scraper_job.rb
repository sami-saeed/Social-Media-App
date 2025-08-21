require "uri"
require "open-uri"

class LinkScraperJob
  include Sidekiq::Job

  def perform(url, user_id)
    uri = safe_uri(url)
    return unless uri

    user = User.find(user_id)
    scraped = LinkScraper.new(url).call
    platform_info = detect_platform(url)

    post = Post.new(
      title: scraped[:title].presence || "Imported post",
      content: scraped[:text].presence || "No text found.",
      user: user,
      platform_name: platform_info[:name],
      platform_logo: platform_info[:logo]
    )

    if scraped[:image_url].present?
      attach_remote_image(post, scraped[:image_url], url)
    end

    post.save!

    # Optional: broadcast to ActionCable if needed
    # ActionCable.server.broadcast(
    #   "link_scraper_#{post.id}",
    #   {
    #     html: ApplicationController.render(
    #       partial: "posts/show",
    #       locals: { post: post }
    #     )
    #   }
    # )
  end

  private

  def attach_remote_image(record, image_url, referer)
    io = URI.open(
      image_url,
      "User-Agent" => "Mozilla/5.0",
      "Referer"    => referer,
      read_timeout: 20,
      open_timeout: 10
    )
    filename = File.basename(URI.parse(image_url).path.presence || "image.jpg")
    record.image.attach(io: io, filename: filename)
  rescue => e
    Rails.logger.warn("Image attach failed: #{e.class}: #{e.message}")
  end

  def detect_platform(url)
    host = URI.parse(url).host
    return { name: "Unknown", logo: nil } unless host

    host = host.sub(/^www\./, "") # Normalize host
    case host
    when /facebook\.com/i
      { name: "Facebook", logo: "https://logo.clearbit.com/facebook.com" }
    when /twitter\.com/i, /x\.com/i
      { name: "Twitter", logo: "https://logo.clearbit.com/twitter.com" }
    when /instagram\.com/i
      { name: "Instagram", logo: "https://logo.clearbit.com/instagram.com" }
    else
      { name: host.capitalize, logo: "https://logo.clearbit.com/#{host}" }
    end
  end

  def safe_uri(url)
    return nil if url.blank?

    # Encode unsafe characters to prevent URI::InvalidURIError
    URI.parse(URI::DEFAULT_PARSER.escape(url))
  rescue URI::InvalidURIError
    nil
  end
end
