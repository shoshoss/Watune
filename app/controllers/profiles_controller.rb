# app/controllers/profiles_controller.rb
class ProfilesController < ApplicationController
  before_action :set_user, only: %i[show edit update]

  def show
    params[:category] ||= "self"
    @pagy, @posts = pagy_countless(filtered_posts, items: 10)
    Rails.logger.debug("Filtered posts: #{@posts.inspect}") # デバッグ用ログ
    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('posts', partial: 'profiles/posts', locals: { posts: @posts, pagy: @pagy })
      end
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user.avatar.attach(params[:user][:avatar]) if @user.avatar.blank?
    if @user.update(user_params)
      redirect_to profile_show_path(username_slug: @user.username_slug), status: :see_other, notice: 'プロファイルが更新されました。'
    else
      flash.now[:error] = 'プロファイルの更新に失敗しました。'
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(current_user.id)
  end

  def user_params
    params.require(:user).permit(:display_name, :email, :avatar, :username_slug, :self_introduction)
  end

  def filtered_posts
    base_scope = case params[:category]
                 when 'self'
                   @user.posts
                 when 'likes'
                   @user.liked_posts.visible_to(@user)
                 else
                   Post.open
                 end
    
                 Rails.logger.debug("Base scope: #{base_scope.to_sql}") # デバッグ用ログ
    base_scope.includes(:user).order(created_at: :desc)
  end
end
