module Users
  module Reposts
    extend ActiveSupport::Concern

    included do
      has_many :reposts, dependent: :destroy
      has_many :reposted_posts, through: :reposts, source: :post
    end

    def repost(post)
      reposts.create(post: post)
    end

    def un_repost(post)
      reposts.find_by(post: post)&.destroy
    end

    def repost?(post)
      reposts.exists?(post: post)
    end
  end
end
