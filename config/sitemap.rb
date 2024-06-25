# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = 'http://www.watune.com'

SitemapGenerator::Sitemap.create do
  add root_path, priority: 1.0, changefreq: 'daily'
  add privacy_policy_path, priority: 0.5, changefreq: 'monthly'
  add terms_of_use_path, priority: 0.5, changefreq: 'monthly'

  # ユーザーのプロフィールページ
  User.find_each do |user|
    add profile_show_path(user.username_slug), priority: 0.8, lastmod: user.updated_at
  end

  # 投稿ページ
  Post.find_each do |post|
    add user_post_path(post.user.username_slug, post), priority: 0.7, lastmod: post.updated_at
  end
end
