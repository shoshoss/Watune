class StaticPagesController < ApplicationController
  skip_before_action :require_login, only: [:top]

  def top
    @user = User.new
  end
end
