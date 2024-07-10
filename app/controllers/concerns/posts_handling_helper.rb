module PostsHandlingHelper
  extend ActiveSupport::Concern

  private

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

  def cache_headers(blob)
    blob.metadata[:cache_control] = 'public, max-age=31536000'
    blob.save
  end
end
