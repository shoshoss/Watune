class ProfilesController < ApplicationController
  before_action :set_user, only: %i[show edit update]
  before_action :set_posts, only: %i[show update]

  # プロフィール表示アクション
  def show
    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('profile-posts', partial: 'profiles/show_posts', locals: { posts: @posts, pagy: @pagy })
      end
    end
  end

  # プロフィール編集アクション
  def edit
  end

  # プロフィール更新アクション
def update
  @user.avatar.attach(params[:user][:avatar]) if @user.avatar.blank?
  if @user.update(user_params)
    flash.now[:notice] = t('defaults.flash_message.updated', item: Profile.model_name.human)
    params[:category] ||= 'self'
    @pagy, @posts = pagy_countless(filtered_posts, items: 10)
    respond_to do |format|
      format.html { redirect_to profile_show_path(@user.username_slug), status: :see_other }
      format.turbo_stream
    end
  else
    flash.now[:danger] = t('defaults.flash_message.not_updated', item: Profile.model_name.human)
    respond_to do |format|
      format.html { render :edit, status: :unprocessable_entity }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace('flash_messages', partial: 'shared/flash_message'),
          turbo_stream.replace('error_messages_frame', partial: 'shared/error_messages', locals: { object: @user })
        ]
      end
    end
  end
end


  private

  # 現在のユーザーを設定
  def set_user
    @user = current_user
  end

  # 投稿をフィルタリングして設定
  def set_posts
    params[:category] ||= 'self'
    @pagy, @posts = pagy_countless(filtered_posts, items: 10)
  end

  # 許可されたパラメータを設定
  def user_params
    params.require(:user).permit(:display_name, :email, :avatar, :username_slug, :self_introduction)
  end

  # フィルタリングされた投稿を取得
  def filtered_posts
    base_scope = case params[:category]
                 when 'self'
                   @user.posts
                 when 'likes'
                   @user.liked_posts.visible_to(@user)
                 else
                   Post.open
                 end
    base_scope.includes(:user).order(created_at: :desc)
  end
end
