class LinkScraperChannel < ApplicationCable::Channel
  def subscribed
    # Could be personalized: stream_from "link_scraper_#{current_user.id}"
    stream_from "link_scraper_#{params[:post_id]}"
  end
end
