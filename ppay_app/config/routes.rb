# frozen_string_literal: true
require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  mount Sidekiq::Web => '/sidekiq'

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == Settings.basic_auth.username &&
      password == Settings.basic_auth.password
  end

  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  root 'advertisements#index'

  resources :advertisements
  resources :exchange_portals, :except => [:new, :create, :edit, :update, :destroy]
  resources :rate_snapshots, :except => [:new, :create, :edit, :update, :destroy]
  resources :payments, only: :index

  namespace :payments do
    resources :deposits, param: :uuid do
      member do
        post :confirm
      end
    end
    resources :withdrawals, param: :uuid
  end

  namespace :api do
    namespace :v1 do
      namespace :payments do
        resources :deposits,    only: :create
        resources :withdrawals, only: :create
      end
    end
  end

  # временно для тестов добавляю таблицу
  # по адресу /sidekiq
  #require 'sidekiq/web'
  #Rails.application.routes.draw do
  #devise_for :users
  #  mount Sidekiq::Web => '/sidekiq'
  #end
end
