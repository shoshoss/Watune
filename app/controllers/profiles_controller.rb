class ProfilesController < ApplicationController
  before_action :set_user, only: %i[show edit update]
  before_action :set_posts, only: %i[show update]

  # プロフィール表示アクション
  def show
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # プロフィール編集アクション
  def edit; end

  # プロフィール更新アクション
  def update
    attach_avatar if avatar_params_present?
    if @user.update(user_params)
      flash.now[:notice] = t('defaults.flash_message.updated', item: Profile.model_name.human)
      set_posts
      # `update.turbo_stream.erb`が自動的にレンダリングされます
    else
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
    @pagy, @posts = pagy_countless(filtered_posts, items: 10)
  end

  # 許可されたパラメータを設定
  def user_params
    params.require(:user).permit(:display_name, :email, :avatar, :username_slug, :self_introduction)
  end

  # アバターパラメータの存在チェック
  def avatar_params_present?
    params[:user][:avatar].present?
  end

  # アバターの添付処理
  def attach_avatar
    @user.avatar.attach(params[:user][:avatar]) if @user.avatar.blank?
  end

  # フィルタリングされた投稿を取得
  def filtered_posts
    scope = case params[:category] ||= 'all'
            when 'all'
              @user.posts
            when 'only_me'
              @user.posts.only_me
            when 'open'
              @user.posts.open
            when 'likes'
              @user.liked_posts.visible_to(@user)
            when 'not_liked_by_me'
              Post.not_liked_by_user(@user)
            when 'with_likes_count'
              Post.with_likes_count
            end
    scope.includes(:user).order(created_at: :desc)
  end
end
