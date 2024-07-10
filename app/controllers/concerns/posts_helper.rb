# app/controllers/concerns/posts_helper.rb
module PostsHelper
  extend ActiveSupport::Concern

  private

  # カテゴリーを取得するメソッド
  def fetch_category
    params[:category] || cookies[:selected_post_category] || 'recommended'
  end

  # 指定されたカテゴリーに基づいて投稿を取得するメソッド
  def fetch_posts_by_fixed_category(category)
    categories = {
      'praise_gratitude' => Post.fixed_categories[:praise_gratitude],
      'music' => Post.fixed_categories[:music],
      'child' => Post.fixed_categories[:child],
      'favorite' => Post.fixed_categories[:favorite],
      'skill' => Post.fixed_categories[:skill],
      'monologue' => Post.fixed_categories[:monologue],
      'other' => Post.fixed_categories[:other]
    }
    if category == 'recommended'
      Post.recommended
    else
      fixed_category = categories[category] || Post.recommended
      Post.open.where(fixed_category: fixed_category)
    end
  end

  # カスタムカテゴリーを設定するメソッド
  def assign_custom_category
    custom_category = Category.find_or_create_by(category_name: post_params[:fixed_category],
                                                 add_category_name: post_params[:custom_category])
    @post.category = custom_category
  end

  # 成功した投稿作成の処理
  def handle_successful_create
    flash[:notice] = t('defaults.flash_message.created', item: Post.model_name.human, default: '投稿が作成されました。')
    PostCreationJob.perform_later(@post.id, post_params[:recipient_ids], @post.privacy) if post_params[:recipient_ids].present?
    redirect_based_on_privacy
  end

  # 失敗した投稿作成の処理
  def handle_failed_create
    flash.now[:danger] = t('defaults.flash_message.not_created', item: Post.model_name.human, default: '投稿の作成に失敗しました。')
    render :new, status: :unprocessable_entity
  end

  # カテゴリーごとのパス設定
  def category_path(category)
    path_mappings = {
      'recommended' => 'recommended',
      'praise_gratitude' => 'praise_gratitude',
      'music' => 'music',
      'child' => 'child',
      'favorite' => 'favorite',
      'skill' => 'skill',
      'monologue' => 'monologue',
      'other' => 'other'
    }
    posts_path(category: path_mappings[category] || 'recommended')
  end

  # プライバシー設定に基づくリダイレクト先を決定する
  def redirect_based_on_privacy
    case params[:privacy] || @post.privacy
    when 'only_me'
      redirect_to_only_me
    when 'selected_users'
      redirect_for_selected_users
    when 'open'
      redirect_to_open_category
    else
      redirect_to_default
    end
  end

  # プライバシー設定が「only_me」の場合のリダイレクト処理
  def redirect_to_only_me
    redirect_to profile_show_path(username_slug: current_user.username_slug,
                                  category: 'only_me'),
                status: :see_other,
                notice: flash[:notice]
  end

  # プライバシー設定が「selected_users」の場合のリダイレクト処理
  def redirect_for_selected_users
    recipient_ids = post_params[:recipient_ids]
    if recipient_ids.blank?
      redirect_to_only_me
    elsif recipient_ids.size > 1
      redirect_to profile_show_path(username_slug: current_user.username_slug,
                                    category: 'my_posts_following'),
                  status: :see_other,
                  notice: flash[:notice]
    elsif recipient_user
      redirect_to profile_show_path(username_slug: recipient_user.username_slug,
                                    category: 'shared_with_you'),
                  status: :see_other,
                  notice: flash[:notice]
    end
  end

  # プライバシー設定が「open」の場合のリダイレクト処理
  def redirect_to_open_category
    category = @post.fixed_category || 'recommended'
    redirect_to category_path(category), status: :see_other, notice: flash[:notice]
  end

  # その他のプライバシー設定の場合のリダイレクト処理
  def redirect_to_default
    redirect_to user_post_path(current_user.username_slug, @post), status: :see_other, notice: flash[:notice]
  end

  # 受信者ユーザーを取得するメソッド
  def recipient_user
    recipient_id = post_params[:recipient_ids]&.first
    User.find(recipient_id) if recipient_id && post_params[:recipient_ids].size == 1
  end

  # 表示用の変数を設定するメソッド
  def setup_show_variables
    @show_reply_line = true
    @notifications = current_user&.received_notifications&.unread
    @reply = Post.new
    @pagy, @replies = pagy_countless(@post.replies.includes(:user, :replies, :likes, :bookmarks).order(created_at: :asc),
                                     items: 15)
    @parent_posts = @post.ancestors
  end

  # オーディオファイルのキャッシュヘッダーを設定するメソッド
  def cache_headers(blob)
    blob.metadata[:cache_control] = 'public, max-age=31536000'
    blob.save
  end

  # オーディオファイルのファイル名を変更するメソッド
  def rename_audio_file(post)
    audio = post.audio
    new_filename = "#{post.id}_#{SecureRandom.uuid}#{File.extname(audio.filename.to_s)}"
    audio.blob.update(filename: new_filename)
  end

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
    params.require(:post).permit(:user_id, :body, :audio, :duration, :privacy, :fixed_category, :custom_category, :post_reply_id,
                                 recipient_ids: [])
  end

  # フォローしているユーザーを投稿数でソートする
  def set_followings_by_post_count
    @sorted_followings = current_user.following_ordered_by_sent_posts
  end

  # 投稿の表示権限を確認する
  def authorize_view!
    return if @post.visible_to?(current_user)

    redirect_to root_path, alert: 'この投稿を見る権限がありません。'
  end

  # オーディオファイルを変換するメソッド
  def convert_audio(file_path)
    output_path = file_path.sub(File.extname(file_path), '.mp3')
    system("ffmpeg -i #{file_path} #{output_path}")
    output_path
  end
end
