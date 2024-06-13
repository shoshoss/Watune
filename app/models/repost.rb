class Repost < ApplicationRecord
  belongs_to :user
  belongs_to :original_post, class_name: 'Post', foreign_key: 'post_id'
end
