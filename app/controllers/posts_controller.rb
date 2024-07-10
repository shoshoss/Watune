# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  include PostsHelper
  include ActionView::RecordIdentifier

  skip_before_action :require_login, only: %i[index show]
  before_action :set_post, only: %i[show edit update destroy]
  before_action :set_current_user_post, only: %i[edit update destroy]
  before_action :set_followings_by_post_count, only: %i[new edit create update]
  before_action :authorize_view!, only: [:show]

  # 投稿一覧を表示するアクション
  def index
    # URLパラメータのカテゴリーが存在しない場合、クッキーからカテゴリーを取得
    category = params[:category] || cookies[:selected_post_category] || 'recommended'

    # 選択されたカテゴリーをクッキーに保存
    cookies[:selected_post_category] = { value: category, expires: 1.year.from_now } if params[:category]

    # 選択されたカテゴリーに基づいて投稿を取得
    @pagy, @posts = pagy_countless(fetch_posts_by_category(category), items: 5)
  end

  # 投稿詳細を表示するアクション
  def show
    @show_reply_line = true
    # 現在のユーザーの未読通知を取得
    @notifications = current_user&.received_notifications&.unread
    @reply = Post.new
    @pagy, @replies = pagy_countless(@post.replies.includes(:user, :replies, :likes, :bookmarks).order(created_at: :asc),
                                     items: 15)
    # 親投稿を取得
    @parent_posts = @post.ancestors
  end

  # 新しい投稿フォームを表示するアクション
  def new
    @post = Post.new
    params[:privacy] ||= @post.privacy
  end

  # 投稿を編集するフォームを表示するアクション
  def edit; end

  # 新しい投稿を作成するアクション
  def create
    @post = current_user.posts.build(post_params.except(:recipient_ids, :custom_category))

    assign_custom_category if post_params[:custom_category].present?

    if @post.save
      handle_successful_create
    else
      handle_failed_create
    end
  end

  # 投稿を更新するアクション
  def update
    if @post.update(post_params.except(:recipient_ids))
      assign_custom_category if post_params[:custom_category].present?

      # オーディオファイルにキャッシュヘッダーを設定
      cache_headers(@post.audio) if @post.audio.attached?

      PostCreationJob.perform_later(@post.id, post_params[:recipient_ids], @post.privacy) if post_params[:recipient_ids].present?
      flash[:notice] = t('defaults.flash_message.updated', item: Post.model_name.human, default: '投稿が更新されました。')
      redirect_to user_post_path(current_user.username_slug, @post)
    else
      flash.now[:danger] = t('defaults.flash_message.not_updated', item: Post.model_name.human, default: '投稿の更新に失敗しました。')
      render :edit, status: :unprocessable_entity
    end
  end

  # 投稿を削除するアクション
  def destroy
    @post.destroy!
    flash.now[:notice] = t('defaults.flash_message.deleted', item: Post.model_name.human, default: '投稿が削除されました。')
    respond_to do |format|
      format.html { redirect_to posts_path, status: :see_other }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(dom_id(@post)),
          turbo_stream.update('flash', partial: 'shared/flash_message', locals: { flash: })
        ]
      end
    end
  end

  private

  # 指定されたカテゴリーに基づいて投稿を取得するメソッド
  def fetch_posts_by_category(category)
    if category == 'recommended'
      posts = Post.open.reposted.ordered_by_latest_activity
    else
      posts = Post.open.ordered_by_latest_activity

      categories = {
        'praise_gratitude' => Post.fixed_categories[:praise_gratitude],
        'music' => Post.fixed_categories[:music],
        'child' => Post.fixed_categories[:child],
        'favorite' => Post.fixed_categories[:favorite],
        'skill' => Post.fixed_categories[:skill],
        'monologue' => Post.fixed_categories[:monologue],
        'other' => Post.fixed_categories[:other]
      }

      fixed_category = categories[category] || Post.fixed_categories[:recommended]
      posts = posts.where(fixed_category:)
    end

    posts
  end

  # カスタムカテゴリーを設定するメソッド
  def assign_custom_category
    custom_category = Category.find_or_create_by(category_name: post_params[:fixed_category],
                                                 add_category_name: post_params[:custom_category])
    @post.category = custom_category
  end

  # 成功した投稿作成の処理
  def handle_successful_create
    flash[:notice] = t('defaults.flash_message.created', item: Post.model_name.human, default: '投稿が作成されました。')

    # 非同期処理のキック: R2への音声ファイルの保存や通知の作成など
    PostCreationJob.perform_later(@post.id, post_params[:recipient_ids], @post.privacy) if post_params[:recipient_ids].present?

    redirect_based_on_privacy
  end

  # 失敗した投稿作成の処理
  def handle_failed_create
    flash.now[:danger] = t('defaults.flash_message.not_created', item: Post.model_name.human, default: '投稿の作成に失敗しました。')
    render :new, status: :unprocessable_entity
  end

  # カテゴリーごとのパス設定
  def category_path(category)
    case category
    when 'recommended'
      posts_path(category: 'recommended')
    when 'praise_gratitude'
      posts_path(category: 'praise_gratitude')
    when 'music'
      posts_path(category: 'music')
    when 'child'
      posts_path(category: 'child')
    when 'favorite'
      posts_path(category: 'favorite')
    when 'skill'
      posts_path(category: 'skill')
    when 'monologue'
      posts_path(category: 'monologue')
    when 'other'
      posts_path(category: 'other')
    else
      posts_path(category: 'recommended')
    end
  end

  # プライバシー設定に基づくリダイレクト先を決定する
  def redirect_based_on_privacy
    case params[:privacy] || @post.privacy
    when 'only_me'
      redirect_to profile_show_path(username_slug: current_user.username_slug, category: 'only_me'), status: :see_other,
                                                                                                     notice: flash[:notice]
    when 'selected_users'
      if post_params[:recipient_ids].size == 1
        recipient = User.find(post_params[:recipient_ids].first)
        redirect_to profile_show_path(username_slug: recipient.username_slug, category: 'shared_with_you'), status: :see_other,
                                                                                                            notice: flash[:notice]
      else
        redirect_to profile_show_path(username_slug: current_user.username_slug, category: 'my_posts_following'),
                    status: :see_other, notice: flash[:notice]
      end
    when 'open'
      category = @post.fixed_category || 'recommended'
      redirect_to category_path(category), status: :see_other, notice: flash[:notice]
    else
      redirect_to user_post_path(current_user.username_slug, @post), status: :see_other, notice: flash[:notice]
    end
  end
end
