class Repost < ApplicationRecord
  belongs_to :user
  belongs_to :post
  belongs_to :original_post, class_name: 'Post'

  validates :body, length: { maximum: 10_000 }, allow_nil: true
end
