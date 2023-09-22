Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post '/create_telegram_application', to: 'telegram_applications#create'
      post '/update_telegram_application', to: 'telegram_applications#update'
    end
  end
end