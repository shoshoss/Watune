class ChangeDurationToDecimalInPosts < ActiveRecord::Migration[7.1]
  def change
    change_column :posts, :duration, :decimal, precision: 10, scale: 2
  end
end
