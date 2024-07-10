class AddIndexToPostsOnFixedCategory < ActiveRecord::Migration[7.1]
  def change
    add_index :posts, :fixed_category
  end
end
