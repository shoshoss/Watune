# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :require_login

  private

  def not_authenticated
    flash[:error] = t('defaults.flash_message.require_login')
    redirect_to login_path, status: :found
  end
end
