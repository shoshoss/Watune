class AddLatestActivityToExistingPosts < ActiveRecord::Migration[7.1]
  def up
    Post.find_each do |post|
      latest_time = [post.created_at, post.reposts.maximum(:created_at)].compact.max
      post.update(latest_activity: latest_time)
    end
  end

  def down
    # no-op
  end
end
