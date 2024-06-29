module UsersHelper
  def following_button_class(location: nil)
    if location == :widget
      'min-w-[118px] ml-[12px]'
    else
      'min-w-[124px]'
    end
  end

  def follow_button_class(location: nil)
    if location == :widget
      'min-w-[90px] ml-[12px]'
    else
      'min-w-[94px]'
    end
  end
end
