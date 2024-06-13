module Users
  module Reposts
    extend ActiveSupport::Concern

    included do
      has_many :reposts, dependent: :destroy
      has_many :reposted_posts, through: :reposts, source: :post
    end

    def repost(post)
      reposts.create(post_id: post.id)
    end

    def un_repost(post)
      reposts.find_by(post_id: post.id)&.destroy
    end

    def repost?(post)
      reposts.exists?(post_id: post.id)
    end
  end
end
