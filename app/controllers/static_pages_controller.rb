class StaticPagesController < ApplicationController
  skip_before_action :require_login, only: %i[top about privacy_policy terms_of_use privacy_modal tou_modal]

  def top
    # 無限スクロールのための投稿データを取得
    @pagy, @posts = pagy_countless(fetch_posts, items: 10)
  end

  def about; end

  def privacy_policy; end

  def terms_of_use; end

  def privacy_modal; end

  def tou_modal; end

  private

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
end
