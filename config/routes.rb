# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  root 'static_pages#top'

  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
  delete 'logout', to: 'user_sessions#destroy'
  
  # get と post のリクエストをまとめるために match を使用
  match 'oauth/callback', to: 'oauths#callback', via: [:get, :post]
  get 'oauth/:provider', to: 'oauths#oauth', as: :auth_at_provider

  resources :users, only: %i[new create]
  resource :profile, only: %i[edit update]
  resources :password_resets, only: %i[new create edit update]
end
