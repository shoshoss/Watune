class Notification < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  belongs_to :notifiable, polymorphic: true

  validates :recipient_id, presence: true
  validates :action, presence: true

  scope :unread, -> { where(unread: true) }
end
