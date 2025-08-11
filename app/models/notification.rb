class Notification < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :actor, class_name: "User"
  belongs_to :notifiable, polymorphic: true



  scope :unread, -> { where(read_at: nil) }

   after_create_commit do
    # You can send JSON or pre-rendered HTML
    ActionCable.server.broadcast(
      "notifications_#{recipient.id}",
      {
        id: id,
        action: action,
        notifiable_type: notifiable_type,
        notifiable_id: notifiable_id,
        message: "#{actor.username} #{action}",
        created_at: created_at.strftime("%H:%M %p"),
        unread_count: recipient.notifications.unread.count
      }
    )
    end
end
