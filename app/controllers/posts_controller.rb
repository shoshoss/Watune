class PostsController < ApplicationController
  include ActionView::RecordIdentifier

  skip_before_action :require_login, only: %i[index show]
  before_action :set_post, only: %i[show edit update destroy]
  before_action :set_current_user_post, only: %i[edit update destroy]
  before_action :set_followings_by_post_count, only: %i[new_test create_test new edit create update]
  before_action :authorize_view!, only: [:show]

  # テスト用の音声投稿フォームを表示するアクション
  def new_test
    @post = Post.new
    params[:privacy] ||= @post.privacy
  end

  def index_test
    @show_reply_line = false
    # 無限スクロールのための投稿データを取得
    @pagy, @posts = pagy_countless(fetch_posts, items: 10)
  end

  def create_test
    @post = current_user.posts.build(post_params.except(:recipient_ids))
    if @post.save
      if @post.audio.attached?
        convert_to_mp3(@post.audio)
      end
      flash[:notice] = "投稿が作成されました。"
      redirect_to user_post_path(current_user.username_slug, @post)
    else
      flash.now[:alert] = "投稿の作成に失敗しました。"
      render :new_test
    end
  end

  # 投稿一覧を表示するアクション
  def index
    @show_reply_line = false
    # 無限スクロールのための投稿データを取得
    @pagy, @posts = pagy_countless(fetch_posts, items: 10)
  end

  # 投稿詳細を表示するアクション
  def show
    @show_reply_line = true
    # 現在のユーザーの未読通知を取得
    @notifications = current_user&.received_notifications&.unread
    @reply = Post.new
    # 返信データを取得し、ページネーションを設定
    @pagy, @replies = pagy_countless(@post.replies.includes(:user, :replies, :likes, :bookmarks).order(created_at: :asc),
                                     items: 15)
    # 親投稿を取得
    @parent_posts = @post.ancestors
  end

  # 新しい投稿フォームを表示するアクション
  def new
    @post = Post.new
    params[:privacy] ||= @post.privacy
  end

  # 投稿を編集するフォームを表示するアクション
  def edit; end

  # 新しい投稿を作成するアクション
  def create
    @post = current_user.posts.build(post_params.except(:recipient_ids))
    if @post.save
      if post_params[:recipient_ids].present?
        PostCreationJob.perform_later(@post.id, post_params[:recipient_ids],
                                      @post.privacy)
      end
      flash[:notice] = t('defaults.flash_message.created', item: Post.model_name.human, default: '投稿が作成されました。')
      redirect_to user_post_path(current_user.username_slug, @post)
    else
      flash.now[:danger] = t('defaults.flash_message.not_created', item: Post.model_name.human, default: '投稿の作成に失敗しました。')
      render :new, status: :unprocessable_entity
    end
  end

  # 投稿を更新するアクション
  def update
    if @post.update(post_params.except(:recipient_ids))
      if post_params[:recipient_ids].present? || @post.privacy == 'selected_users'
        PostCreationJob.perform_later(@post.id, post_params[:recipient_ids], @post.privacy)
      end
      flash[:notice] = t('defaults.flash_message.updated', item: Post.model_name.human, default: '投稿が更新されました。')
      redirect_to user_post_path(current_user.username_slug, @post)
    else
      flash.now[:danger] = t('defaults.flash_message.not_updated', item: Post.model_name.human, default: '投稿の更新に失敗しました。')
      render :edit, status: :unprocessable_entity
    end
  end

  # 投稿を削除するアクション
  def destroy
    @post.destroy!
    flash.now[:notice] = t('defaults.flash_message.deleted', item: Post.model_name.human, default: '投稿が削除されました。')
    respond_to do |format|
      format.html { redirect_to posts_path, status: :see_other }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(dom_id(@post)),
          turbo_stream.update('flash', partial: 'shared/flash_message', locals: { flash: })
        ]
      end
    end
  end

  private

  # 特定の投稿をセットする
  def set_post
    @post = Post.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'この投稿は存在しません。'
  end

  # ログインユーザーの投稿をセットする
  def set_current_user_post
    @post = current_user.posts.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'この投稿は存在しません。'
  end

  # 投稿のパラメータを許可する
  def post_params
    params.require(:post).permit(:user_id, :body, :audio, :duration, :privacy, :post_reply_id, recipient_ids: [])
  end

  # フォローしているユーザーを投稿数でソートする
  def set_followings_by_post_count
    @sorted_followings = current_user.following_ordered_by_sent_posts
  end

  # 投稿一覧を取得するメソッド
  def fetch_posts
    latest_reposts = Repost.select('DISTINCT ON (post_id) *')
                           .order('post_id, created_at DESC')

    Post.open
        .select('posts.*, COALESCE(latest_reposts.created_at, posts.created_at) AS reposted_at')
        .joins("LEFT JOIN (#{latest_reposts.to_sql}) AS latest_reposts ON latest_reposts.post_id = posts.id")
        .includes(:user, :reposts, :replies, :likes, :bookmarks) # 関連データを一度にロードする
        .order(Arel.sql('reposted_at DESC'))
  end

  # 投稿の表示権限を確認する
  def authorize_view!
    return if @post.visible_to?(current_user)

    redirect_to root_path, alert: 'この投稿を見る権限がありません。'
  end

  def convert_to_mp3(audio)
    input_file = audio.download
    temp_file = Tempfile.new(['input', File.extname(audio.filename.to_s)])
    temp_file.binmode
    temp_file.write(input_file.read)
    temp_file.rewind

    output_file = "#{Rails.root}/tmp/#{SecureRandom.uuid}.mp3"

    begin
      Rails.logger.info("Converting audio to MP3: #{temp_file.path}")
      movie = FFMPEG::Movie.new(temp_file.path)
      movie.transcode(output_file, audio_codec: 'libmp3lame')

      Rails.logger.info("MP3 conversion complete: #{output_file}")

      audio.attach(
        io: File.open(output_file),
        filename: "#{SecureRandom.uuid}.mp3",
        content_type: 'audio/mpeg'
      )
    rescue => e
      Rails.logger.error("MP3 conversion failed: #{e.message}")
    ensure
      temp_file.close
      temp_file.unlink
      File.delete(output_file) if File.exist?(output_file)
    end
  end
end
