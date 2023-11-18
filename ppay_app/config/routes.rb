# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  mount Sidekiq::Web => '/sidekiq'
  authenticate :user, ->(user) { user.admin? } do
    mount PgHero::Engine, at: 'pghero'
  end

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == Settings.basic_auth.username &&
      password == Settings.basic_auth.password
  end

  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

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

  scope module: :super_admins, constraints: ->(request) { request.env['warden'].user&.super_admin? } do
    resources :turnover_stats, only: %i[index] do
      collection do
        get :all_stats
      end
    end
    resources :balances, only: %i[index]
    resources :balance_requests

    root 'turnover_stats#index', as: :superadmins_root
  end

  scope module: :admins, constraints: ->(request) { request.env['warden'].user&.admin? } do
    resource :setting, only: %i[edit update]
    resources :advertisements, except: %i[new create]
    resources :balance_requests
    resources :payments, param: :uuid, only: %i[index update show]
    resources :incoming_requests
    resources :masks
    resources :not_found_payments, only: %i[index show destroy]
    resource :dashboard, only: :show, controller: :dashboard
    resources :telegram_applications
    resources :telegram_bots
    namespace :payments do
      resources :deposits, param: :uuid, only: %i[index update show edit]
      resources :withdrawals, param: :uuid, only: %i[index update show edit]
    end

    resources :merchants, only: %i[index new create update] do
      scope module: :merchants do
        resource :account, only: %i[show update]
        resource :settings, only: %i[show update]
        resources :merchant_methods, only: %i[create destroy]
        resource :whitelisted_processers, only: %i[show update]
      end
    end

    resources :processers, only: %i[index new create update] do
      scope module: :processers do
        resource :settings, only: %i[show update]
      end
    end

    resources :turnover_stats, only: %i[index]

    resources :payment_systems, only: :index
    post :payment_systems, to: '/admins/payment_systems#update'

    root 'payments#index', as: :admins_root
  end

  scope module: :agents, constraints: ->(request) { request.env['warden'].user&.agent? } do
    resources :turnover_stats, only: %i[index]
    resources :payments, param: :uuid, only: %i[index show]
    resources :balance_requests

    namespace :payments do
      resources :deposits, param: :uuid, only: %i[index show]
      resources :withdrawals, param: :uuid, only: %i[index show]
    end

    root 'payments#index', as: :agents_root
  end

  scope module: :merchants, constraints: ->(request) { request.env['warden'].user&.merchant? } do
    resources :payments, only: :index
    resources :balance_requests
    resources :arbitrations, only: [:index]
    resources :payment_receipts, only: :create
    resources :transactions, only: [:index]
    namespace :payments do
      resources :deposits, param: :uuid, only: %i[index show create update new] do
        member do
          get :display_link
        end
      end
      resources :withdrawals, param: :uuid, only: %i[index show]
    end

    namespace :users do
      get :settings
      patch :settings, to: '/merchants/users#settings_update'
    end

    root 'payments#index', as: :merchants_root
  end

  namespace :merchants do
    resource :profile, only: %i[edit update]
  end

  namespace :processers do
    resource :profile, only: %i[edit update]
  end

  namespace :supports do
    resource :profile, only: %i[edit update]
  end

  namespace :admins do
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
    resources :incoming_requests
    resources :exchange_portals, only: %i[index show]
    resources :rate_snapshots, only: %i[index show]
    resources :balance_requests
    resources :payments, param: :uuid, only: %i[index update show]
    resource :dashboard, only: :show, controller: :dashboard
    resources :arbitrations, only: [:index]
    namespace :payments do
      resources :deposits, param: :uuid, only: %i[index show update]
      resources :withdrawals, param: :uuid, only: %i[index show update]

      concerns :statuses_updatable
    end

    namespace :users do
      get :settings
      resource :otp, only: %i[show update], controller: :otp
      get :check_telegram_connection_status
    end

    root 'payments#index', as: :processers_root
  end

  scope module: :supports, constraints: ->(request) { request.env['warden'].user&.support? } do
    resources :advertisements, except: %i[new create]
    resources :balance_requests
    resources :payments, param: :uuid, only: %i[index update show]
    resources :not_found_payments, only: %i[index show destroy]
    resources :incoming_requests
    resource :dashboard, only: :show, controller: :dashboard
    resources :arbitrations, only: [:index]
    resources :payment_receipts, only: :create
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

  scope module: :working_groups, constraints: ->(request) { request.env['warden'].user&.working_group? } do
    resources :payments, param: :uuid, only: %i[index show]
    resource :dashboard, only: :show, controller: :dashboard
    resources :balance_requests

    namespace :payments do
      resources :deposits, param: :uuid, only: %i[index show]
      resources :withdrawals, param: :uuid, only: %i[index show]
    end

    root 'payments#index', as: :working_groups_root
  end

  scope module: :ppays, constraints: ->(request) { request.env['warden'].user&.ppay? } do
    resources :balance_requests

    root 'balance_requests#index', as: :ppays_root
  end

  namespace :api do
    namespace :v1 do
      post '/catcher/ping', to: 'mobile_app_requests#ping', as: :catcher_ping
      post '/simbank/requests', to: 'incoming_requests#create', as: :simbank_request
      get :balance, to: 'balance#show'
      resources :payments, param: :uuid, only: :show
      resources :merchant_methods, only: :index

      post '/check_telegram_connections/check_connection_status',
           to: 'check_telegram_connections#check_connection_status'

      concerns :payments_creatable
      namespace :external_processing do
        namespace :payments do
          patch '/bnn_update_callback', to: 'base#bnn_update_callback'
          post '/bnn_update_callback', to: 'base#bnn_update_callback'
        end
        concerns :payments_creatable
        patch 'payments/:uuid/statuses/:event', to: 'payments/statuses#update'
        post 'payments/:uuid/payment_receipts', to: 'payments/payment_receipts#create'
      end
    end
  end

  resources :payments, param: :uuid, only: [] do
    resources :comments, only: :create, controller: 'payments/comments'
    resources :chats, only: :create, controller: 'payments/chats'
  end

  resources :payment_receipts, only: :create

  get 'users/otp', to: 'users/otp#show', as: :user_otp
  post 'users/otp', to: 'users/otp#verify', as: :verify_user_otp
  get 'get-api-link', to: 'api/v1/mobile_app_requests#api_link'

  constraints(
    lambda do |request|
      request.env['warden'].user.blank? &&
        request.path[
          %r{^/(advertisement|merchant|balance_request|payment|rate_snapshot|exchange_portal|payment_systems|users|$)}
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
