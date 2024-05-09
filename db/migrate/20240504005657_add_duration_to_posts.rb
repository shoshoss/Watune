class AddDurationToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :duration, :integer, null: true
  end
end
