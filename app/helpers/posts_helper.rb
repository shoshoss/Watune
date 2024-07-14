module PostsHelper
  CATEGORY_ICONS = {
    'recommended' => 'fa fa-star text-yellow-400-accent',
    'praise_gratitude' => 'fa fa-sun text-orange-400',
    'music' => 'fa fa-music text-blue-500',
    'child' => 'fa fa-smile-o text-pink-400',
    'skill' => 'fa-solid fa-lightbulb text-yellow-400-accent',
    'favorite' => 'fa fa-heart text-red-500',
    'monologue' => 'fa fa-comment-dots text-teal-500',
    'other' => 'fa fa-ellipsis-h text-gray-500'
  }.freeze

  CATEGORY_NAMES = {
    'recommended' => 'おすすめ',
    'praise_gratitude' => '褒めや感謝',
    'music' => '音楽',
    'child' => '子供の声',
    'skill' => '特技や技術',
    'favorite' => '好きなことや自己紹介',
    'monologue' => 'ひとりごと',
    'other' => 'その他'
  }.freeze

  # カテゴリに対応するアイコンのクラスを返すメソッド
  def category_icon(category)
    CATEGORY_ICONS[category] || 'fa fa-circle text-gray-500'
  end

  # カテゴリ名を適切な形式に変換するメソッド
  def category_name(category)
    CATEGORY_NAMES[category] || '不明なカテゴリー'
  end
end
