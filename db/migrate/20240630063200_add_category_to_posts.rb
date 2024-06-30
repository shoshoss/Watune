class AddCategoryToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :fixed_category, :integer, default: 0, null: false
    add_reference :posts, :category, foreign_key: true
  end
end
