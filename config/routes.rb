# frozen_string_literal: true

Rails.application.routes.draw do
  get 'render/index'

  # Defines the root path route ("/")
  root 'static_pages#top'
end
