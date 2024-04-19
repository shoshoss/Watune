# frozen_string_literal: true

module ApplicationHelper
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
end
