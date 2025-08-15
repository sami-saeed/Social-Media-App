class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, -> { where(parent_id: nil).order(created_at: :desc) }, dependent: :destroy
  has_one_attached :image
  validates :title, :content, presence: true
end
