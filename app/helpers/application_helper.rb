# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def page_title(title = '')
    base_title = 'Watune（ウェーチュン）'
    title.present? ? "#{title} | #{base_title}" : base_title
  end

  def set_flash(key, message)
    session[key] = message
  end

  def get_flash(key)
    message = session[key]
    session.delete(key)
    message
  end

  def before_profile_edit_flash
    flash[:before_profile_edit] || {}
  end

  def flash_class(type)
    case type.to_sym
    when :notice
      'alert alert-info'       # 青色の背景
    when :success
      'alert alert-success'    # 緑色の背景
    when :error
      'alert alert-error'      # 赤色の背景
    when :alert, :danger
      'alert alert-warning'    # 黄色の背景
    else
      'alert alert-default'    # デフォルト（グレー）の背景
    end
  end

  # 投稿一覧
  # \nだけ置換
  def nl2br(input)
    (sanitize input).gsub("\n", '<br>')
  end

  # プロフィール画面 paramsの値に応じてアクティブクラスを適用

  # タブがアクティブかどうかを決定するクラスを返す
  def active_tab_class(*categories, initial_category:)
    active_category = params[:category] || initial_category

    return '' unless categories.include?(active_category)

    category_classes = {
      'all_my_posts' => 'c-tab-active c-tab-active-all-my-posts',
      'only_me' => 'c-tab-active c-tab-active-all-my-posts',
      'my_posts_following' => 'c-tab-active c-tab-active-all-my-posts',
      'my_posts_open' => 'c-tab-active c-tab-active-all-my-posts',
      'posts_to_you' => 'c-tab-active c-tab-active-posts-to-you',
      'all_likes_chance' => 'c-tab-active c-tab-active-all-likes-chance',
      'my_likes_chance' => 'c-tab-active c-tab-active-all-likes-chance',
      'public_likes_chance' => 'c-tab-active c-tab-active-all-likes-chance',
      'bookmarked' => 'c-tab-active c-tab-active-bookmarked',
      'liked' => 'c-tab-active c-tab-active-liked',
      'followings' => 'c-tab-active',
      'followers' => 'c-tab-active'
    }

    category_classes[active_category] || 'c-tab-active'
  end

  # 投稿画面 paramsの値に応じてアクティブクラスを適用
  def active_bottom(privacy_value)
    params[:privacy] == privacy_value ? 'btn-choice-active' : ''
  end

  def active_if(path)
    current_page?(path) ? 'font-bold border-b-4 border-sky-400-accent text-blue-500' : 'font-medium border-b-2 border-gray-200'
  end

  # ユーザー数と投稿数を表示
  def format_count(count)
    if count >= 1_000_000
      "#{(count / 1_000_000.0).round(1)}M"
    elsif count >= 1_000
      "#{(count / 1_000.0).round(1)}K"
    else
      count.to_s
    end
  end

  # ウィジェットがメインコンテンツと同じように表示されないように
  def hide_widget_on_users_index
    controller_name == 'users' && action_name == 'index' ? 'hidden' : ''
  end
end
