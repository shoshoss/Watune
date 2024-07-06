class AddUniqueIndexToCategories < ActiveRecord::Migration[7.1]
  def change
    # 既存のインデックスを削除
    remove_index :categories, :add_category_name if index_exists?(:categories, :add_category_name)

    # ユニークインデックスを追加
    add_index :categories, :add_category_name, unique: true
  end
end
