class ApplicationController < ActionController::Base
  include ApplicationHelper
  include Pagy::Backend

  before_action :require_login
  before_action :set_recent_users, if: :logged_in?
  before_action :set_unfollowed_users_count, if: :logged_in?
  before_action :set_notifications, if: :logged_in?

  private

  def not_authenticated
    flash[:danger] = t('defaults.flash_message.require_login')
    redirect_to login_path, status: :found
  end

  # ユーザーがログインしているかどうかを確認するメソッド
  def logged_in?
    current_user.present?
  end

  # 新規登録ユーザーを設定
  def set_recent_users
    @recent_users = User.recently_registered(current_user).limit(5)
  end

  # 未フォローのユーザー数を設定
  def set_unfollowed_users_count
    @unfollowed_users_count = User.recently_registered(current_user).count
  end

  def set_notifications
    @notifications = current_user&.received_notifications&.unread&.limit(10)
    @unread_count = Rails.cache.fetch("user_#{current_user.id}_unread_count", expires_in: 1.minute) do
      current_user.received_notifications.unread.count
    end
  end
end
