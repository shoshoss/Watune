# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :require_login
  before_action :set_user_and_post_count

  private

  def not_authenticated
    flash[:danger] = t('defaults.flash_message.require_login')
    redirect_to new_login_modal_path, status: :found
  end

  def set_user_and_post_count
    @user_count = User.count
    @post_count = Post.count
  end
end
