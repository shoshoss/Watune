class StaticPagesController < ApplicationController
  skip_before_action :require_login, only: %i[top about privacy_policy terms_of_use privacy_modal tou_modal]
  before_action :redirect_if_logged_in, only: :top

  def top; end

  def about
    @user = User.new
  end

  def privacy_policy; end

  def terms_of_use; end

  def privacy_modal; end

  def tou_modal; end

  private

  def redirect_if_logged_in
    redirect_to posts_path if logged_in?
  end
end
