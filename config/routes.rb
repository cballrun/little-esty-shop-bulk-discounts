Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/merchants/:id/dashboard', to: 'merchants#dashboard'

  root to: 'welcome#index'

  resources :merchants do
    resources :invoices, only: [:index, :show]
    resources :items, only: [:index, :show, :edit, :update, :new, :create]
    resources :invoice_items, only: [:update]
    resources :bulk_discounts
  end

  namespace :admin do
    resources :merchants, only: [:index, :show, :edit, :update, :new, :create]
    resources :invoices, only: [:index, :show, :update]
  end

  resources :admin, only: [:index]

end
