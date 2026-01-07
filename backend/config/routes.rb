Rails.application.routes.draw do
  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      resources :life_events
      resources :annual_budgets
      resource :simulation, only: [:show]
    end
  end
end
