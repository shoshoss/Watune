module PostsHelper
  extend ActiveSupport::Concern

  private

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

    output_file = Rails.root.join("tmp/#{SecureRandom.uuid}.mp3").to_s

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
    rescue StandardError => e
      Rails.logger.error("MP3 conversion failed: #{e.message}")
    ensure
      temp_file.close
      temp_file.unlink
      FileUtils.rm_f(output_file)
    end
  end
end
