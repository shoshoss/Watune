class Post < ApplicationRecord
  include Posts::LikeScopes
  include Posts::UserPostScopes
  include Posts::SharedScopes
  include Posts::Notification

  attr_accessor :recipient_ids

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
  validates :duration, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_thanまたはequal_to: 3599 },
                       allow_nil: true

  enum privacy: { only_me: 0, reply: 1, open: 2, selected_users: 10, community: 20, only_direct: 30 }

  after_create :create_post_users_and_notify

  # 投稿の可視性を判定するメソッド
  def visible_to?(user)
    return true if self.user == user # 投稿者本人
    return true if privacy == 'open' # 全体公開
    return true if privacy == 'reply' # リプライ

    post_users.exists?(user:, approved: true) # 承認された受信者
  end

  # 親の投稿のユーザー名が重複しないように祖先を取得するメソッド
  def ancestors
    parents = []
    current_post = self
    while current_post.parent_post
      parents << current_post.parent_post
      current_post = current_post.parent_post
    end
    parents.reverse
  end

  # コールバック
  def create_post_users_and_notify
    if direct? && recipient_ids.present?
      recipient_ids.each do |recipient_id|
        post_users.create(user_id: recipient_id, role: 'direct_recipient')
      end
      notify_async('direct_post')
    elsif reply?
      notify_async('reply')
    end
  end

  # 非同期通知を実行する
  def notify_async(notification_type)
    NotificationJob.perform_later(notification_type, self.id)
  end

  private

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
