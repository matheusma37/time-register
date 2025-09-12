Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  scope :api, defaults: { format: :json } do
    namespace :v1 do
      resources :users do
        post :reports, on: :member

        resources :time_registers, only: [ :index ], controller: :time_logs
      end
      resources :time_registers, controller: :time_logs
      resources :reports, param: :process_id, only: [] do
        member do
          get :status
          get :download
        end
      end
    end
  end
end
