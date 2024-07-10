module PostsCreationHelper
  extend ActiveSupport::Concern

  private

  # カスタムカテゴリーを設定するメソッド
  def assign_custom_category
    custom_category = Category.find_or_create_by(category_name: post_params[:fixed_category],
                                                 add_category_name: post_params[:custom_category])
    @post.category = custom_category
  end

  # 成功した投稿作成の処理
  def handle_successful_create
    flash[:notice] = t('defaults.flash_message.created', item: Post.model_name.human, default: '投稿が作成されました。')
    PostCreationJob.perform_later(@post.id, post_params[:recipient_ids], @post.privacy) if post_params[:recipient_ids].present?
    redirect_based_on_privacy
  end

  # 失敗した投稿作成の処理
  def handle_failed_create
    flash.now[:danger] = t('defaults.flash_message.not_created', item: Post.model_name.human, default: '投稿の作成に失敗しました。')
    render :new, status: :unprocessable_entity
  end
end
