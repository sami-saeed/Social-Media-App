class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: "parent_id", dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :mentions, dependent: :destroy
  has_many :mentioned_users, through: :mentions, source: :mentioned_user
end
