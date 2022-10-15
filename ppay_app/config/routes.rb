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

  scope module: :processers do
    root 'payments#index'
  end

  scope module: :merchants, constraints: lambda { |request| request.env['warden'].user&.merchant? } do
    resources :payments, only: :index
    namespace :payments do
      resources :deposits, only: :index
      resources :withdrawals, only: :index
    end
    root 'payments#index', as: :merchants_root
  end

  scope module: :processers, constraints: lambda { |request| request.env['warden'].user&.processer? } do
    resources :advertisements
    resources :exchange_portals, only: %i[index show]
    resources :rate_snapshots, only: %i[index show]
    resources :payments, only: %i[index update]
    namespace :payments do
      resources :deposits, only: :index
      resources :withdrawals, only: :index
    end
    root 'payments#index', as: :processers_root
  end

  namespace :payments do
    resources :deposits, param: :uuid, only: %i[update show]
    resources :withdrawals, param: :uuid, only: %i[update show]
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
