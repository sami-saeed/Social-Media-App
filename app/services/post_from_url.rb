# app/services/post_from_url.rb
require "open-uri"

class PostFromUrl
  def initialize(url, current_user)
    @url = url
    @current_user = current_user
  end

  def call
    scraped = LinkScraper.new(@url).call

    post = Post.new(
      title:   scraped[:title].presence || "Imported post",
      content: scraped[:text].presence  || "No text found."
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
end
