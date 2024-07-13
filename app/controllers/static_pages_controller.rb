class StaticPagesController < ApplicationController
  skip_before_action :require_login, only: %i[root top about privacy_policy terms_of_use privacy_modal tou_modal]

  def root
    return unless logged_in?

    redirect_to posts_path(category: cookies[:selected_post_category] || 'recommended')
  end

  def top; end

  def about; end

  def privacy_policy; end

  def terms_of_use; end

  def privacy_modal; end

  def tou_modal; end
end
