class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: "parent_id", dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :mentions, dependent: :destroy
  has_many :mentioned_users, through: :mentions, source: :mentioned_user

  after_create :create_notifications

  private

  def create_notifications
    ActiveRecord::Base.transaction do
      notify_mentioned_users
      notify_post_owner_if_needed
      notify_parent_comment_author_if_needed
    end
  end

  def notify_mentioned_users
    usernames = content.scan(/@(\w+)/).flatten.uniq
    users = User.where(username: usernames)

    users.each do |user|
      next if user ==  self.user # skip self mentions

      Mention.find_or_create_by!(
        comment: self,
        mentioned_user: user,
        mentioner: self.user
      )

      Notification.create!(
        recipient: user,
        actor: self.user,
        notifiable: self,
        action: "tagged you in a comment"
      )
    end
  end

  def notify_post_owner_if_needed
    usernames = content.scan(/@(\w+)/).flatten.uniq
    mentioned_users = User.where(username: usernames)

    if mentioned_users.empty? && post.user != user && parent.nil?
      Notification.create!(
        actor: user,
        recipient: post.user,
        notifiable: self,
        action: "commented on your post"
      )
    end
  end

  def notify_parent_comment_author_if_needed
    return unless parent.present? && parent.user != user

    Notification.create!(
      recipient: parent.user,
      actor: user,
      notifiable: self,
      action: "replied to your comment"
    )

    # Notify post owner if different from parent comment author
    if parent.user != post.user && post.user != user
      Notification.create!(
        actor: user,
        recipient: post.user,
        notifiable: self,
        action: "commented on your post"
      )
    end
  end
end
