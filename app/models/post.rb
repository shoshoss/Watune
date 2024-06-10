# app/models/post.rb
class Post < ApplicationRecord
  include Posts::LikeScopes
  include Posts::UserPostScopes
  include Posts::SharedScopes
  include Posts::Notification

  belongs_to :user
  has_many :replies, class_name: 'Post', foreign_key: :post_reply_id, inverse_of: :parent_post
  belongs_to :parent_post, class_name: 'Post', foreign_key: :post_reply_id, optional: true, inverse_of: :replies
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user
  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_users, through: :bookmarks, source: :user
  has_many :post_users, dependent: :destroy
  has_many :direct_recipients, lambda {
                                 where(post_users: { role: 'direct_recipient' })
                               }, through: :post_users, source: :user
  has_many :community_recipients, lambda {
                                    where(post_users: { role: 'community_recipient' })
                                  }, through: :post_users, source: :user
  has_one_attached :audio

  validates :body, length: { maximum: 10_000 }
  validates :duration, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_thanまたは_equal_to: 3599 },
                       allow_nil: true

  enum privacy: { only_me: 0, reply: 1, open: 2, selected_users: 10, community: 20, only_direct: 30 }

  # コールバック
  after_create_commit :notify_async, if: :needs_notification?

  private

  # 非同期通知を実行する
  def notify_async
    if reply?
      NotificationJob.perform_later('reply', self.id)
    elsif direct?
      NotificationJob.perform_later('direct_post', self.id)
    end
  end

  # 通知が必要かどうかを判定する
  def needs_notification?
    reply? || direct?
  end

  # リプライかどうかを判定する
  def reply?
    post_reply_id.present?
  end

  # ダイレクトポストかどうかを判定する
  def direct?
    privacy == 'selected_users'
  end
end
