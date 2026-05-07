Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Admin authentication
  get    "login",  to: "sessions#new",     as: :login
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  root "dashboard#index"

  # Admin management
  resources :admins

  # Student management
  resources :students do
    collection do
      get  :import
      post :import
      get  :export_csv
    end
  end

  # Course management
  resources :courses do
    resources :lessons, except: [:index]
  end

  # Progress management
  resources :students, only: [] do
    resources :progresses, only: [:index, :create, :update]
  end

  # Email templates
  resources :email_templates do
    member do
      post :send_email
    end
    collection do
      post :bulk_send
    end
  end

  # Email logs
  resources :email_logs, only: [:index, :show]
end
