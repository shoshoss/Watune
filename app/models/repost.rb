class Repost < ApplicationRecord
  belongs_to :user
  belongs_to :original_post, class_name: 'Post', foreign_key: 'post_id', inverse_of: :original_post

  after_create_commit :notify_repost

  private

  def notify_repost
    return if user_id == original_post.user_id

    original_post.create_notification_repost(user)
  end
end
