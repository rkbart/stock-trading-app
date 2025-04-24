Rails.application.routes.draw do
  devise_for :users

  # Admin namespace for managing users
  namespace :admin do
    resources :users, only: [:index] do
      member do
        patch :approve
      end
    end
  end

  # Custom pages
  get "pages/dashboard", to: "pages#dashboard"
  get "pages/profile", to: "pages#profile"
  get "pages/portfolio", to: "pages#portfolio"

  # authenticated :user do
  #   root "pages#dashboard", as: :authenticated_root
  # end
  
  # devise_scope :user do
  #   unauthenticated do
  #     root to: "pages#home", as: :unauthenticated_root
  #   end
  # end
  
  # Root
  root to: "pages#home"
end
