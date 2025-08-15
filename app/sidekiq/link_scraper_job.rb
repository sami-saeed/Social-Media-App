class LinkScraperJob
  include Sidekiq::Job

  def perform(url, user_id)
    user = User.find(user_id)
    scraped = LinkScraper.new(url).call

    post = Post.new(
      title: scraped[:title].presence || "Imported post",
      content: scraped[:text].presence || "No text found.",
      user: user
    )

    if scraped[:image_url].present?
      attach_remote_image(post, scraped[:image_url])
    end

    post.save!


    #    ActionCable.server.broadcast(
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
