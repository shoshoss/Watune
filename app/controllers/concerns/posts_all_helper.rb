module PostsAllHelper
  extend ActiveSupport::Concern

  private

  # 指定されたカテゴリーに基づいて投稿を取得するメソッド
  def fetch_posts_by_fixed_category(category)
    base_query = Post.open

    if category == 'recommended'
      base_query.reposted.order(latest_activity: :desc)
    else
      base_query.where(fixed_category: Post.fixed_categories[category]).order(latest_activity: :desc)
    end
  end

  # カスタムカテゴリーを設定するメソッド
  def assign_custom_category
    custom_category = Category.find_or_create_by(category_name: post_params[:fixed_category],
                                                 add_category_name: post_params[:custom_category])
    @post.category = custom_category
  end

  # プライバシー設定に基づくリダイレクト先を決定する
  def redirect_based_on_privacy
    cookies[:selected_post_category] = post_params[:fixed_category] if post_params[:fixed_category].present?
    current_category = cookies[:selected_post_category] || 'recommended'
    case params[:privacy] || @post.privacy
    when 'only_me'
      redirect_to profile_show_path(username_slug: current_user.username_slug, category: 'only_me'), status: :see_other,
                                                                                                     notice: flash[:notice]
    when 'selected_users'
      recipient_ids = post_params[:recipient_ids]
      if recipient_ids.blank?
        redirect_to_only_me
      elsif recipient_ids.size > 1
        redirect_to profile_show_path(username_slug: current_user.username_slug, category: 'my_posts_following'),
                    status: :see_other, notice: flash[:notice]
      elsif recipient_user
        redirect_to profile_show_path(username_slug: recipient_user.username_slug, category: 'shared_with_you'),
                    status: :see_other, notice: flash[:notice]
      end
    when 'open'
      redirect_to posts_path(category: current_category || 'recommended'), status: :see_other, notice: flash[:notice]
    else
      redirect_to_default
    end
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
