module UsersHelper
  def following_button_class(location: nil)
    if location == :widget
      'min-w-[118px] ml-[12px]'
    elsif params[:controller] == 'profiles' && params[:action] == 'show'
      'min-w-[124px]'
    else
      'min-w-[118px] ml-[12px]'
    end
  end

  def follow_button_class(location: nil)
    if location == :widget
      'min-w-[90px] ml-[12px]'
    elsif params[:controller] == 'profiles' && params[:action] == 'show'
      'min-w-[94px]'
    else
      'min-w-[90px] ml-[12px]'
    end
  end
end
