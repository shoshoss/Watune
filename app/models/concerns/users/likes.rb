module Users
  module Likes
    extend ActiveSupport::Concern

    included do
      has_many :likes, dependent: :destroy
      has_many :liked_posts, through: :likes, source: :post
    end

    def like(post)
      likes.create(post:)
    end

    def unlike(post)
      likes.find_by(post:)&.destroy
    end

    def like?(post)
      likes.exists?(post:)
    end
  end
end
