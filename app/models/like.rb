class Like < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :user_id, uniqueness: { scope: :post_id }

  after_create_commit :create_notification_for_like

  private

  def create_notification_for_like
    return if user_id == post.user_id

    post.create_notification_like(user)
  end
end
