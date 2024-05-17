# app/controllers/profiles_controller.rb
class ProfilesController < ApplicationController
  before_action :set_user, only: %i[show edit update]

  def show
    params[:category] ||= 'self'
    @pagy, @posts = pagy_countless(filtered_posts, items: 10)
    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('profile-posts', partial: 'profiles/show_posts',
                                                           locals: { posts: @posts, pagy: @pagy })
      end
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user.avatar.attach(params[:user][:avatar]) if @user.avatar.blank?
    if @user.update(user_params)
      flash.now[:notice] = t('defaults.flash_message.updated', item: Profile.model_name.human)
      respond_to do |format|
        format.html { redirect_to profile_show_path(@user.username_slug), status: :see_other }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace('flash_messages', partial: 'shared/flash_message'),
            turbo_stream.replace('profile_edit_frame', partial: 'profiles/show', locals: { user: @user, posts: @posts, pagy: @pagy })
          ]
        end
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
    base_scope.includes(:user).order(created_at: :desc)
  end
end
