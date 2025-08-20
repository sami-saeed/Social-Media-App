class Like < ApplicationRecord
  belongs_to :user
  belongs_to :comment

  validates :user_id, uniqueness: { scope: :comment_id }
   after_create :create_notifications

  private

  def create_notifications
    # Notify the comment owner
    if user != comment.user
      Notification.create!(
        recipient: comment.user,
        actor: user,
        notifiable: comment,
        action: "liked your comment"
      )
    end

    # Notify the post owner (if different from comment owner and liker)
    if comment.post.user != comment.user && user != comment.post.user
      Notification.create!(
        recipient: comment.post.user,
        actor: user,
        notifiable: comment,
        action: "liked a comment in your post"
      )
    end
  end
end
