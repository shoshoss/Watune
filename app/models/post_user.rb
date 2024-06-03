class PostUser < ApplicationRecord
  belongs_to :post
  belongs_to :user

  validates :role, presence: true, inclusion: { in: %w[direct_recipient reply_recipient community_recipient] }

  enum role: { direct_recipient: 'direct_recipient', reply_recipient: 'reply_recipient',
               community_recipient: 'community_recipient' }
end
