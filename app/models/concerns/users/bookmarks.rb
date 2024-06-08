module Users
  module Bookmarks
    extend ActiveSupport::Concern

    included do
      has_many :bookmarks, dependent: :destroy
      has_many :bookmarked_posts, through: :bookmarks, source: :post
    end

    def bookmark(post)
      bookmarks.create(post:)
    end

    def unbookmark(post)
      bookmarks.find_by(post:)&.destroy
    end

    def bookmarked?(post)
      bookmarks.exists?(post:)
    end
  end
end
