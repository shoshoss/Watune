module PostsHelper
  # カテゴリに対応するアイコンのクラスを返すメソッド
  def category_icon(category)
    case category
    when 'recommended'
      'fa fa-star text-yellow-400-accent'
    when 'praise_gratitude'
      'fa fa-sun text-orange-400'
    when 'music'
      'fa fa-music text-blue-500'
    when 'child'
      'fa fa-smile-o text-pink-400'
    when 'skill'
      'fa-solid fa-lightbulb text-yellow-400-accent'
    when 'favorite'
      'fa fa-heart text-red-500'
    when 'monologue'
      'fa fa-comment-dots text-teal-500'
    when 'other'
      'fa fa-ellipsis-h text-gray-500'
    else
      'fa fa-circle text-gray-500'
    end
  end

  # カテゴリ名を適切な形式に変換するメソッド
  def category_name(category)
    case category
    when 'recommended'
      'おすすめ'
    when 'praise_gratitude'
      '褒めや感謝'
    when 'music'
      '音楽'
    when 'child'
      '子供の声'
    when 'skill'
      '特技や技術'
    when 'favorite'
      '好きなことや自己紹介'
    when 'monologue'
      'ひとりごと'
    when 'other'
      'その他'
    else
      category.titleize
    end
  end
end
