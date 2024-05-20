class AddPostReplyIdToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :post_reply_id, :integer
    add_index :posts, :post_reply_id
  end
end
