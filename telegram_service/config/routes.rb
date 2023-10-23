require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  namespace :api do
    namespace :v1 do
      post '/create_telegram_application', to: 'telegram_applications#create'
      post '/update_telegram_application', to: 'telegram_applications#update'
      get '/check_job_status/:phone_number', to: 'telegram_applications#check_job_status'
    end
  end
end