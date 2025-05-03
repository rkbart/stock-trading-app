Rails.application.routes.draw do
  get "pages/home"
  devise_for :users

  namespace :admin do
    resources :users, only: [ :index, :show, :edit, :update ] do
      member do
        patch :approve
        patch :reject
      end

      collection do
        get :show_all_traders
        get :invite_trader
        get :all_transactions
        post :send_invite
      end
    end
  end

  resources :users, only: [] do
    member do
      patch :change_role, to: "pages#change_role"
    end
  end

  # Dashboard
  get "dashboard", to: "dashboard#index"
  authenticated :user do
    root "dashboard#index"
  end

  # Portfolio
  resource :portfolios, only: [ :show ]
  get "portfolio", to: "portfolios#show"

  # Stocks
  resources :stocks, only: [ :index, :show ]

  # Transactions
  resources :transactions, only: [ :index ]

  # Buy/Sell
  resources :buys, only: [ :new, :create ]
  get "buys/new/:symbol", to: "buys#new", as: "new_buy_with_symbol"

  resources :sells, only: [ :new, :create ]
  get "sells/new/:symbol", to: "sells#new", as: "new_sell_with_symbol"

  # Deposits
  resources :deposits, only: [ :new, :create ]
  get "deposit_form", to: "pages#deposit_form", as: :deposit_form

  # Settings
  resource :settings, only: [ :show, :update ]
  patch "settings/update_role", to: "settings#update_role"

  # Profiles
  resource :profile, only: [ :edit, :update, :show ]

  # About
  get "about", to: "pages#about"

  # Home
  get "home", to: "pages#home"

  devise_scope :user do
    unauthenticated do
      root to: "devise/sessions#new", as: :unauthenticated_root
    end
  end
end
