require 'rails_helper'

RSpec.describe MarkNotificationsAsReadJob do
  let(:user) { create(:user) }
  let!(:notifications) { create_list(:notification, 3, user:, unread: true) }

  it 'marks all notifications as read' do
    expect do
      described_class.perform_now(user)
    end.to change { Notification.where(unread: true).count }.from(3).to(0)
  end
end
