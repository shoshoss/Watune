class Repost < ApplicationRecord
  belongs_to :user
  belongs_to :post
  belongs_to :original_post
end
