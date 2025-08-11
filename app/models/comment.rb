class Comment < ApplicationRecord
after_create_commit :notify_post_owner

  belongs_to :user
  belongs_to :post
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: "parent_id", dependent: :destroy
  has_many :likes, dependent: :destroy



  def notify_post_owner
    return if post.user == user_id
    Notification.create(
      recipient: post.user,
      actor: user,
      action: "commented",
      notifiable: self
    )
  end
end
