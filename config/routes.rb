Rails.application.routes.draw do
  devise_for :users
  
  root "dashboard#index"

  get "up" => "rails/health#show", as: :rails_health_check

  resources :mood_entries, path: 'moods' do
    collection do
      get :quick_entry
      post :create_quick
    end
  end

  resources :analytics, only: [:index] do
    collection do
      get :mood_trends
      get :trigger_analysis
      get :wellness_report
    end
  end

  resources :resources do
    member do
      post :like
      post :bookmark
      post :view
    end
    collection do
      get :bookmarked
    end
  end

  resources :triggers, only: [:index, :show]

  namespace :profile do
    root "settings#index"
    get :settings
    patch :update_settings
    get :privacy
    get :export_data
  end

  namespace :api do
    namespace :v1 do
      resources :mood_entries, only: [:index, :create, :show]
      resources :analytics, only: [:index]
    end
  end
end
