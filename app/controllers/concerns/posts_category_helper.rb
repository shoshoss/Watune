module PostsCategoryHelper
  extend ActiveSupport::Concern

  private

  # カテゴリーを取得するメソッド
  def fetch_category
    params[:category] || cookies[:selected_post_category] || 'recommended'
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

  # 指定されたカテゴリーに基づいて投稿を取得するメソッド
  def fetch_posts_by_category(category)
    posts = Post.open.ordered_by_latest_activity
    return posts.reposted if category == 'recommended'

    categories = {
      'praise_gratitude' => Post.fixed_categories[:praise_gratitude],
      'music' => Post.fixed_categories[:music],
      'child' => Post.fixed_categories[:child],
      'favorite' => Post.fixed_categories[:favorite],
      'skill' => Post.fixed_categories[:skill],
      'monologue' => Post.fixed_categories[:monologue],
      'other' => Post.fixed_categories[:other]
    }
    fixed_category = categories[category] || Post.fixed_categories[:recommended]
    posts.where(fixed_category:)
  end
end
