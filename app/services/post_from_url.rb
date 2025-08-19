# app/services/post_from_url.rb
require "open-uri"
require "uri"

class PostFromUrl
  def initialize(url, current_user)
    @url = url
    @current_user = current_user
  end

  def call
    scraped = LinkScraper.new(@url).call
    platform_info = detect_platform(@url)

    post = Post.new(
      title:   scraped[:title].presence || "Imported post",
      content: scraped[:text].presence  || "No text found.",
      platform_logo: platform_info[:logo],
      platform_name: platform_info[:name]
    )
    post.user = @current_user

    if scraped[:image_url].present?
      attach_remote_image(post, scraped[:image_url])
    end

    post.save!
    post
  end

  private

  def attach_remote_image(record, image_url)
    io = URI.open(image_url,
                  "User-Agent" => "Mozilla/5.0",
                  "Referer"    => @url,
                  read_timeout: 20,
                  open_timeout: 10)
    filename = File.basename(URI.parse(image_url).path.presence || "image.jpg")
    record.image.attach(io: io, filename: filename)
  rescue => e
    Rails.logger.warn("Image attach failed: #{e.class}: #{e.message}")
  end


  def detect_platform(url)
    host = URI.parse(url).host
     return nil unless host

     host = host.sub(/^www\./, "") # Normalize to remove www prefix
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
end
