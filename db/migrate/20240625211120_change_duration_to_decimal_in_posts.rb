class ChangeDurationToDecimalInPosts < ActiveRecord::Migration[7.1]
  def up
    change_column :posts, :duration, :decimal, precision: 10, scale: 2
  end

  def down
    change_column :posts, :duration, :integer
  end
end
