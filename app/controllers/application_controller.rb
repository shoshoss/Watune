class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :require_login
  before_action :set_likes_chance_count, if: :logged_in?

  private

  def not_authenticated
    flash[:danger] = t('defaults.flash_message.require_login')
    redirect_to new_login_modal_path, status: :found
  end

  # いいねチャンス数を設定
  def set_likes_chance_count
    return unless logged_in?

    likes_chance_counts = Post.with_likes_count_all(current_user).count
    @likes_chance_count = likes_chance_counts.values.sum
  end

  # ユーザーがログインしているかどうかを確認するメソッド
  def logged_in?
    current_user.present?
  end
end
