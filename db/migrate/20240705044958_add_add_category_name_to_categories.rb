class AddAddCategoryNameToCategories < ActiveRecord::Migration[7.1]
  def change
    add_column :categories, :add_category_name, :string
  end
end
