class CommentsController < ApplicationController
  # after_action :broadcast_notification, only: [:create]

  def create
    if params[:post_id]
      # Comment on a post
      @post = Post.find(params[:post_id])
      @comment = @post.comments.build(comment_params)
      @comment.user = current_user
    else
      # Reply to a comment
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
        # Notify mentioned users
        mentioned_users.each do |user|
          next if user == current_user

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

        # Notify post owner if no mentions and not self
        if mentioned_users.empty? && @post.user != current_user && !@comment.parent
          Notification.create!(
            actor: current_user,
            recipient: @post.user,
            notifiable: @comment,
            action: "commented on your post"
          )
        end

        # Notify parent comment author if replying and not self
        if @comment.parent.present? && @comment.parent.user != current_user
          Notification.create(
            recipient: @comment.parent.user,
            actor: current_user,
            notifiable: @comment,
            action: "replied to your comment"
          )

          # Notify post owner if different from parent comment author
          if @comment.parent.user != @post.user && @post.user != current_user
            Notification.create!(
              actor: current_user,
              recipient: @post.user,
              notifiable: @comment,
              action: "commented on your post"
            )
          end
        end
      end

      redirect_back fallback_location: root_path, notice: "Comment Posted"
    else
      redirect_back fallback_location: root_path, alert: "Error Posting Comment"
    end
  end

  def destroy
    @comment = Comment.find_by(id: params[:id])
    if @comment.present? && @comment.user == current_user
      @comment.destroy
      flash[:alert] = "Comment deleted"
    else
      flash[:alert] = "You are not authorized to delete this comment."
    end

    redirect_back fallback_location: root_path
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
