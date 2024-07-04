class AssignCategoryJob < ApplicationJob
  queue_as :default

  def perform(post_id, category_name)
    post = Post.find(post_id)
    custom_category = Category.find_or_create_by(category_name:)
    post.update(category: custom_category)
  end
end
