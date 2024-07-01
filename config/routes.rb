# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  root 'static_pages#top'

  get 'about', to: 'static_pages#about'
  get 'privacy_policy', to: 'static_pages#privacy_policy'
  get 'terms_of_use', to: 'static_pages#terms_of_use'
  # モーダル用のプライバシーと利用規約
  get 'privacy_modal', to: 'static_pages#privacy_modal'
  get 'tou_modal', to: 'static_pages#tou_modal'

  resources :users, only: %i[index new create destroy] do
    resource :friendships, only: %i[create destroy]
  end
  get ':username_slug/following', to: 'friendships#index', defaults: { category: 'following' }, as: 'user_following'
  get ':username_slug/followers', to: 'friendships#index', defaults: { category: 'followers' }, as: 'user_followers'

  get 'guest_login', to: 'users#guest_login', as: 'guest_login'
  # モーダル用の新規登録ルーティング
  get 'signup_modal', to: 'users#new_modal', as: 'new_signup_modal'
  post 'signup_modal', to: 'users#create_modal', as: 'create_signup_modal'

  # get と post のリクエストをまとめるために match を使用
  match 'oauth/callback', to: 'oauths#callback', via: %i[get post]
  get 'oauth/:provider', to: 'oauths#oauth', as: :auth_at_provider

  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
  delete 'logout', to: 'user_sessions#destroy'

  # モーダル用のログインルーティング
  get 'login_modal', to: 'user_sessions#new_modal', as: 'new_login_modal'
  post 'login_modal', to: 'user_sessions#create_modal', as: 'create_login_modal'

  resources :notifications, only: %i[index] do
    collection do
      get :unread_count
    end
  end
  resource :notification_settings, only: %i[edit update]

  # パスワードリセットのルーティング
  resources :password_resets, only: %i[new create edit update]

  # 投稿のルーティング
  resources :waves, controller: 'posts', as: 'posts', except: [:show] do
    collection do
      get :privacy_settings
    end
    resources :likes, only: %i[create destroy]
    resources :bookmarks, only: %i[create destroy]
    resources :reposts, only: %i[create destroy]
  end
  get '/:username_slug/status/:id', to: 'posts#show', as: :user_post

  post '/:username_slug/status/:id/replies', to: 'replies#create', as: 'user_post_replies'
  get '/:username_slug/status/:id/reply_modal', to: 'replies#new_modal', as: 'new_reply_modal'
  post '/:username_slug/status/:id/reply_modal', to: 'replies#create_modal', as: 'create_reply_modal'

  # テスト用の音声投稿ページのルートを追加
  get 'posts/new_test', to: 'posts#new_test', as: 'new_test_post'

  # テスト用の新しい投稿作成ルート
  post 'posts/create_test', to: 'posts#create_test', as: 'create_test_post'

  get '/posts/index_test', to: 'posts#index_test', as: :index_test_post

  # PostUserのルーティング（投稿受信者管理）
  resources :post_users, only: %i[show create destroy]

  # プロフィールのルーティング
  resource :profile, only: %i[edit update]
  # プロフィールモーダルのルーティング
  get '/profiles/:username_slug/modal', to: 'profiles#modal', as: 'profile_modal'
  # プロフィールの詳細のルーティング
  get '/:username_slug', to: 'profiles#show', as: :profile_show
end
