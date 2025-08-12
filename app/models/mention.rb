class Mention < ApplicationRecord
  belongs_to :comment
  belongs_to :mentioned_user, class_name: "User"
  belongs_to :mentioner, class_name: "User"

  validates :comment_id, uniqueness: { scope: :mentioned_user_id }
end
