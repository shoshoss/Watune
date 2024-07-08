class Repost < ApplicationRecord
  belongs_to :user
  belongs_to :original_post, class_name: 'Post', foreign_key: 'post_id', inverse_of: :reposts

  after_create_commit :notify_repost

  after_create :update_original_post_activity

  private

  def notify_repost
    return if user_id == original_post.user_id

    original_post.create_notification_repost(user)
  end

  def update_original_post_activity
    original_post.update(latest_activity: created_at)
  end
end
