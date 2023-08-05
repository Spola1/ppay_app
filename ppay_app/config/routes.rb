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

  devise_for :users # , controllers: {
  #   registrations: 'users/registrations'
  # }

  concern :statuses_updatable do
    namespace :statuses do
      resources :deposits, param: :uuid, only: :update
      resources :withdrawals, param: :uuid, only: :update
    end
  end

  namespace :payments, constraints: ->(request) { request.params[:signature].present? } do
    resources :deposits, param: :uuid, only: %i[show update]
    resources :withdrawals, param: :uuid, only: %i[show update]

    concerns :statuses_updatable
  end

  scope module: :admins, constraints: ->(request) { request.env['warden'].user&.admin? } do
    resource :setting, only: [:edit, :update]
    resources :advertisements, except: %i[new create]
    resources :balance_requests
    resources :payments, param: :uuid, only: %i[index update show]
    resources :incoming_requests
    resources :masks
    resources :not_found_payments, only: %i[index show destroy]
    namespace :payments do
      resources :deposits, param: :uuid, only: %i[index update show edit]
      resources :withdrawals, param: :uuid, only: %i[index update show edit]
    end

    resources :merchants, only: %i[index new create update] do
      scope module: :merchants do
        resource :account, only: %i[show update]
        resource :settings, only: %i[show update]
        resources :merchant_methods, only: %i[create destroy]
      end
    end

    resources :turnover_stats, only: %i[index]

    resources :payment_systems, only: :index
    post :payment_systems, to: '/admins/payment_systems#update'

    root 'payments#index', as: :admins_root
  end

  scope module: :merchants, constraints: ->(request) { request.env['warden'].user&.merchant? } do
    resources :payments, only: :index do
      collection do
        get :arbitration_by_check
      end
    end
    resources :balance_requests
    namespace :payments do
      resources :deposits, param: :uuid, only: %i[index show create update new] do
        member do
          get :display_link
        end
      end
      resources :withdrawals, only: :index
    end

    namespace :users do
      get :settings
      patch :settings, to: '/merchants/users#settings_update'
    end

    root 'payments#index', as: :merchants_root
  end

  namespace :processers do
    resource :profile, only: %i[edit update]
  end

  scope module: :processers, constraints: ->(request) { request.env['warden'].user&.processer? } do
    resources :advertisements do
      collection do
        post :activate_all
        post :deactivate_all
        get :flow
      end
    end
    resources :exchange_portals, only: %i[index show]
    resources :rate_snapshots, only: %i[index show]
    resources :balance_requests
    resources :payments, param: :uuid, only: %i[index update show] do 
      collection do
        get :arbitration_by_check
      end
    end
    namespace :payments do
      resources :deposits, param: :uuid, only: %i[index show update]
      resources :withdrawals, param: :uuid, only: %i[index show update]

      concerns :statuses_updatable
    end

    namespace :users do
      get :settings
    end

    root 'payments#index', as: :processers_root
  end

  scope module: :supports, constraints: ->(request) { request.env['warden'].user&.support? } do
    resources :advertisements, except: %i[new create]
    resources :balance_requests
    resources :payments, param: :uuid, only: %i[index update show] do
      collection do
        get :arbitration_by_check
      end
    end
    resources :not_found_payments, only: %i[index show destroy]
    resources :incoming_requests
    namespace :payments do
      resources :deposits, param: :uuid, only: %i[index update show edit]
      resources :withdrawals, param: :uuid, only: %i[index update show edit]
    end

    root 'payments#index', as: :supports_root
  end

  concern :payments_creatable do
    namespace :payments do
      resources :deposits,    only: :create
      resources :withdrawals, only: :create
    end
  end

  namespace :api do
    namespace :v1 do
      post '/simbank/requests', to: 'incoming_requests#create'
      get :balance, to: 'balance#show'
      resources :payments, param: :uuid, only: :show

      concerns :payments_creatable
      namespace :external_processing do
        concerns :payments_creatable
        patch 'payments/:uuid/statuses/:event', to: 'payments/statuses#update'
      end
    end
  end

  resources :payments, param: :uuid, only: [] do
    resources :comments, only: :create, controller: 'payments/comments'
    resources :chats, only: :create, controller: 'payments/chats'
  end

  constraints(
    lambda do |request|
      request.env['warden'].user.blank? &&
        request.path[
          %r{^/(advertisement|merchant|balance_request|payment|rate_snapshot|exchange_portal|payment_systems|$)}
        ].present?
    end
  ) do
    match '*path', to: 'users/sign_in#index', via: :all
    root 'users/sign_in#index'
  end

  # временно для тестов добавляю таблицу
  # по адресу /sidekiq
  # require 'sidekiq/web'
  # Rails.application.routes.draw do
  # devise_for :users
  #  mount Sidekiq::Web => '/sidekiq'
  # end
end
