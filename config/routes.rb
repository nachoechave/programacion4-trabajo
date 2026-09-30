Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :admin do
    get "login", to: "sessions#new"
    post "login", to: "sessions#create"
    delete "logout", to: "sessions#destroy"

    root "dashboard#index"
    resources :cases, except: :destroy
    resources :evidence_types
    resources :users, except: :destroy
    resources :evidences, except: :destroy do
      member do
        get :report
      end
      resources :transfers, only: %i[new create]
    end
    resources :custody_movements, only: %i[index show]
  end

  namespace :api do
    namespace :v1 do
      resources :cases, only: %i[index show]
      resources :evidences, only: %i[index show] do
        resources :custody_movements, only: :index
      end
    end
  end

  root to: redirect("/admin")
end
