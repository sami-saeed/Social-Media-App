class NotificationsController < ApplicationController
  before_action :authenticate_user!
  def index
    @notifications = current_user.notifications.order(created_at: :desc)
  end

  def mark_as_read
  @notification = current_user.notifications.find(params[:id])
    @notification.update(read_at: Time.current)
    redirect_to notifications_path, notice: "Notification marked as read."
  end

  def mark_all_as_read
    current_user.notifications.where(read_at: nil).update_all(read_at: Time.current)
    redirect_to notifications_path, notice: "All notifications marked as read."
  end
end
