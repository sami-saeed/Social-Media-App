Rails.application.routes.draw do
  get "notifications/index"
  root "posts#index"

  devise_for :users


  authenticate :user do
    resources :posts do
      resources :comments, only: [ :create ] do
      end
    end


    resources :comments do
      resources :comments, only: [ :create, :destroy ]
      resource :like, only: [ :create, :destroy ]
    end

    resources :users, only: [ :index, :show ]


    resources :notifications, only: [ :index ] do
  member { patch :mark_as_read }
  collection { patch :mark_all_read }
end
  end



  # Root path logic: guests see home, users see posts
  authenticated :user do
    root to: "posts#index", as: :authenticated_root
  end

  unauthenticated do
    root to: "home#index", as: :unauthenticated_root
  end


  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
