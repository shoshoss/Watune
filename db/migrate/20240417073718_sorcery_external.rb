class SorceryExternal < ActiveRecord::Migration[7.1]
  def change
    create_table :authentications do |t|
      t.references :user, null: false, foreign_key: true # 外部キー制約とインデックスが自動的に追加される
      t.string :provider, null: false
      t.string :uid, null: false

      t.timestamps
    end

    # プロバイダーとUIDの組み合わせのユニークインデックスを追加
    add_index :authentications, %i[provider uid], unique: true
  end
end
