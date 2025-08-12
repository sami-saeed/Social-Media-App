class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar

  has_many :posts, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :notifications, foreign_key: :recipient_id, dependent: :destroy
  has_many :sent_notifications, class_name: "Notification", foreign_key: :actor_id, dependent: :destroy
  has_many :mentions_received, foreign_key: :mentioned_user_id, class_name: "Mention", dependent: :destroy
  has_many :mentions_made, foreign_key: :mentioner_id, class_name: "Mention", dependent: :destroy

  validates :username, presence: true
end
