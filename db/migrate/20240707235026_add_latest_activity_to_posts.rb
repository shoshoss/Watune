class AddLatestActivityToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :latest_activity, :datetime, default: -> { 'CURRENT_TIMESTAMP' }
    add_index :posts, :latest_activity
  end
end
