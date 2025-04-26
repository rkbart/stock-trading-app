Rails.application.routes.draw do
  devise_for :users

  namespace :admin do
    resources :users, only: [ :index ] do
      member do
        patch :approve
        patch :reject
      end
    end
  end

  resources :users, only: [] do
    member do
      patch :change_role, to: "pages#change_role"
    end
  end

  get "pages/dashboard", to: "pages#dashboard"
  get "pages/profile", to: "pages#profile"
  get "pages/portfolio", to: "pages#portfolio"
  get "settings", to: "pages#settings", as: :settings
  get "transactions", to: "pages#transactions", as: :transactions
  get "buy_stocks", to: "pages#buy"
  post "buy_stocks", to: "pages#perform_buy"

  get "sell_stocks", to: "pages#sell"
  post "sell_stocks", to: "pages#perform_sell"

  get "deposit_form", to: "pages#deposit_form", as: :deposit_form
  post "process_deposit", to: "pages#process_deposit", as: :process_deposit

  root to: "pages#dashboard"
end
