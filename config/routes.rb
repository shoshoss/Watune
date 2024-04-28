# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  root 'static_pages#top'

  # モーダル用のログインルーティング
  get 'login_modal', to: 'user_sessions#new_modal', as: 'new_login_modal'
  post 'login_modal', to: 'user_sessions#create_modal', as: 'create_login_modal'

  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
  delete 'logout', to: 'user_sessions#destroy'

  # get と post のリクエストをまとめるために match を使用
  match 'oauth/callback', to: 'oauths#callback', via: %i[get post]
  get 'oauth/:provider', to: 'oauths#oauth', as: :auth_at_provider

  resources :users, only: %i[new create]
  # モーダル用の新規登録ルーティング
  get 'signup_modal', to: 'users#new_modal', as: 'new_signup_modal'
  post 'signup_modal', to: 'users#create_modal', as: 'create_signup_modal'

  resource :profile, only: %i[edit update]
  resources :password_resets, only: %i[new create edit update]
end
