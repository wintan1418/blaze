Rails.application.routes.draw do
  devise_for :users

  # Public pages
  root "pages#home"
  get "/about",   to: "pages#about",   as: :about
  get "/contact", to: "pages#contact", as: :contact

  # Menu
  resources :menu_categories, only: [ :index, :show ], path: "menu"
  resources :menu_items, only: [ :index, :show ], path: "menu-items"

  # Gaming
  resources :gaming_slots, only: [ :index, :show ], path: "gaming" do
    resource :booking, only: [ :new, :create ], module: :gaming_slots
  end

  # Cinema
  resources :screenings, only: [ :index, :show ], path: "cinema" do
    resource :booking, only: [ :new, :create ], module: :screenings
  end

  # Bookings dashboard
  resources :bookings, only: [ :index, :show ] do
    member { post :cancel }
  end

  # Locations
  resources :locations, only: [ :index, :show ]

  # Admin (hand-rolled)
  namespace :admin do
    root to: "dashboard#index"
    resource  :site_setting, only: [ :edit, :update ], path: "settings"
    resources :hero_slides do
      member { patch :toggle; patch :move_up; patch :move_down }
    end
    resources :menu_categories
    resources :menu_items
    resources :locations
    resources :gaming_consoles
    resources :gaming_slots do
      collection { post :generate }
    end
    resources :screens
    resources :screenings
    resources :bookings, only: [ :index, :show, :update ]
    resources :users, only: [ :index, :edit, :update ]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
