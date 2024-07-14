require 'rails_helper'

RSpec.describe MarkNotificationsAsReadJob, type: :job do
  let(:user) { create(:user) }
  let!(:notifications) { create_list(:notification, 3, user: user, unread: true) }

  it "marks all notifications as read" do
    expect {
      described_class.perform_now(user)
    }.to change { Notification.where(unread: true).count }.from(3).to(0)
  end
end
