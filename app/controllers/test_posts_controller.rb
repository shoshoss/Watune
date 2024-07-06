class TestPostsController < ApplicationController
  include PostsHelper
  include ActionView::RecordIdentifier

  before_action :set_followings_by_post_count, only: %i[new create]

  def index
    @show_reply_line = false
    @pagy, @posts = pagy_countless(Post.order(created_at: :desc), items: 20)
  end

  # テスト用の音声投稿フォームを表示するアクション
  def new
    @post = Post.new
    params[:privacy] ||= @post.privacy
  end

  def create
    @post = current_user.posts.build(post_params.except(:recipient_ids))

    if @post.save
      cache_headers(@post.audio.blob) if @post.audio.attached?

      respond_to do |format|
        format.html { redirect_to user_post_path(current_user.username_slug, @post), notice: '投稿が作成されました。' }
        format.json { render json: @post, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, alert: '投稿の作成に失敗しました。' }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end
end
