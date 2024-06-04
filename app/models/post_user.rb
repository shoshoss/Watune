class PostUser < ApplicationRecord
  belongs_to :post
  belongs_to :user

  validates :role, presence: true, inclusion: { in: %w[direct_recipient reply_recipient community_recipient] }

  enum role: { direct_recipient: 'direct_recipient', reply_recipient: 'reply_recipient',
               community_recipient: 'community_recipient' }

               # ユーザーの投稿回数をカウントするスコープ
  scope :user_post_counts, -> {
    select('user_id, COUNT(post_id) as post_count')
      .group(:user_id)
      .order('post_count DESC')
  }
end
