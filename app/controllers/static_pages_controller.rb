class StaticPagesController < ApplicationController
  skip_before_action :require_login, only: %i[top privacy_policy terms_of_use privacy_modal tou_modal]

  def top; end

  def privacy_policy; end

  def terms_of_use; end

  def privacy_modal; end

  def tou_modal; end
end
