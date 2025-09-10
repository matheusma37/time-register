Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  scope :api, defaults: { format: :json } do
    namespace :v1 do
      resources :users do
        resources :time_logs, only: [ :index ]
      end
      resources :time_logs
    end
  end
end
