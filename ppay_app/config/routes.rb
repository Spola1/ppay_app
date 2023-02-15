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

  namespace :payments, constraints: ->(request) { request.params[:signature].present? } do
    resources :deposits, param: :uuid, only: :show
    resources :withdrawals, param: :uuid, only: :show

    namespace :statuses do
      resources :deposits, param: :uuid, only: :update
      resources :withdrawals, param: :uuid, only: :update
    end
  end

  scope module: :admins, constraints: ->(request) { request.env['warden'].user&.admin? } do
    resources :transactions, only: %i[index show]
    resources :balance_requests
    resources :payments, param: :uuid, only: %i[index update show]
    namespace :payments do
      resources :deposits, param: :uuid, only: %i[index update show edit]
      resources :withdrawals, param: :uuid, only: %i[index update show edit]
    end
    root 'payments#index', as: :admins_root
  end

  scope module: :merchants, constraints: ->(request) { request.env['warden'].user&.merchant? } do
    resources :payments, only: :index
    resources :transactions, only: %i[index show]
    resources :balance_requests
    namespace :payments do
      resources :deposits, only: :index
      resources :withdrawals, only: :index
    end
    root 'payments#index', as: :merchants_root
  end

  scope module: :processers, constraints: ->(request) { request.env['warden'].user&.processer? } do
    resources :advertisements
    resources :exchange_portals, only: %i[index show]
    resources :rate_snapshots, only: %i[index show]
    resources :transactions, only: %i[index show]
    resources :balance_requests
    resources :payments, param: :uuid, only: %i[index update show]
    namespace :payments do
      resources :deposits, param: :uuid, only: %i[index show update]
      resources :withdrawals, param: :uuid, only: %i[index show update]

      namespace :statuses do
        resources :deposits, param: :uuid, only: :update
        resources :withdrawals, param: :uuid, only: :update
      end
    end
    root 'payments#index', as: :processers_root
  end

  scope module: :supports, constraints: ->(request) { request.env['warden'].user&.support? } do
    resources :transactions, only: %i[index show]
    resources :balance_requests
    resources :payments, param: :uuid, only: %i[index update show]
    namespace :payments do
      resources :deposits, param: :uuid, only: %i[index update show edit]
      resources :withdrawals, param: :uuid, only: %i[index update show edit]
    end
    root 'payments#index', as: :supports_root
  end

  namespace :api do
    namespace :v1 do
      namespace :payments do
        resources :deposits,    only: :create
        resources :withdrawals, only: :create
      end
    end
  end

  resources :payments, param: :uuid, only: [] do
    resources :comments, only: :create, controller: 'payments/comments'
  end

  scope module: :processers do
    root 'payments#index'
  end

  # временно для тестов добавляю таблицу
  # по адресу /sidekiq
  # require 'sidekiq/web'
  # Rails.application.routes.draw do
  # devise_for :users
  #  mount Sidekiq::Web => '/sidekiq'
  # end
end
