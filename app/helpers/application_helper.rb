# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def page_title(title = '')
    base_title = 'ConGraWa APP'
    title.present? ? "#{title} | #{base_title}" : base_title
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
  def active_tab(*categories)
    initial_category = current_user == @user ? 'all_my_posts' : 'my_posts_open'
    active_category = params[:category] || initial_category
    categories.include?(active_category) ? 'c-tab-active' : ''
  end

  # 投稿画面 paramsの値に応じてアクティブクラスを適用
  def active_bottom(privacy_value)
    params[:privacy] == privacy_value ? 'c-bottom-active' : ''
  end
end
