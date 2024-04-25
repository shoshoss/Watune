# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  root 'static_pages#top'

  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
  delete 'logout', to: 'user_sessions#destroy'

  # get と post のリクエストをまとめるために match を使用
  match 'oauth/callback', to: 'oauths#callback', via: %i[get post]
  get 'oauth/:provider', to: 'oauths#oauth', as: :auth_at_provider

  resources :users, only: %i[new create]
  # モーダル用の新規登録ルーティング
  get 'register', to: 'users#new_modal', as: 'new_modal_user_registration'
  post 'register', to: 'users#create_modal', as: 'create_modal_user_registration'

  resource :profile, only: %i[edit update]
  resources :password_resets, only: %i[new create edit update]
end
