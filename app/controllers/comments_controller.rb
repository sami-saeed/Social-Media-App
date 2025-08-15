class CommentsController < ApplicationController
# after_action :broadcast_notification, only: [ :create ]
def create
      if params[:post_id]
        @post = Post.find(params[:post_id])
        @comment = @post.comments.build(comment_params)
        @comment.user = current_user
      else
        @parent_comment = Comment.find(params[:comment_id])
        @post = @parent_comment.post
        @comment = @post.comments.build(comment_params)
        @comment.user = current_user
        @comment.parent = @parent_comment

      end

  if @comment.save
    usernames = @comment.content.scan(/@(\w+)/).flatten.uniq
    mentioned_users = User.where(username: usernames)

    ActiveRecord::Base.transaction do
      # Create mentions and notify mentioned users
      mentioned_users.each do |user|
        next if user == current_user  # skip self mentions

        Mention.find_or_create_by!(
          comment: @comment,
          mentioned_user: user,
          mentioner: current_user
        )

        Notification.create!(
          recipient: user,
          actor: current_user,
          notifiable: @comment,
          action: "tagged you in a comment"
        )
      end

      # Notify post owner only if no mentioned users and post owner is not comment author
      if mentioned_users.empty? && @post.user != current_user && !@comment.parent
        Notification.create!(
          actor: current_user,
          recipient: @post.user,
          notifiable: @comment,
          action: "commented on your post"
        )
      end
      # Notify parent comment author if replying to a comment and not self
      if @comment.parent.present? && @comment.parent.user != current_user
        Notification.create(
          recipient: @comment.parent.user,
          actor: current_user,
          notifiable: @comment,
          action: "replied to your comment"
        )
         Notification.create!(
          actor: current_user,
          recipient: @post.user,
          notifiable: @comment,
          action: "commented on your post"
        )
      end
    end

    redirect_back fallback_location: root_path, notice: "Comment Posted"
  else
    redirect_back fallback_location: root_path, alert: "Error Posting Comment"
  end
end


  def destroy
    if params[:id]
      @comment = Comment.find_by(id: params[:id])
      if @comment && @comment.user == current_user
         @comment&.destroy
         flash[:alert] = "Comment deleted"
      else
         flash[:alert] = "You are not authorized to delete this comment."
      end

      redirect_back fallback_location: root_path
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end






# def broadcast_notification
# return unless @comment&.persisted?
#  recipient = @comment.post.user
# return if recipient.id == current_user.id
#  ActionCable.server.broadcast(
#  Rails.logger.info "📢 Broadcasting to notifications_#{recipient.id}",
#  "notifications_#{recipient.id}",
#  {
#    notification: @notification,
#    html: ApplicationController.renderer.render(
#      partial: "notifications/notification",
#      locals: { notification: @notification }
# )
# }
# )
# end
