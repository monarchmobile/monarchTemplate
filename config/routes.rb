Outpouring::Application.routes.draw do
  # mount Ckeditor::Engine => '/ckeditor'
  resources :pages
  resources :products
  resources :contacts
  resources :links
  
  resources :articles do
    resources :comments
  end

  devise_for :users, path_names: {sign_in: "login", sign_out: "logout"}, :controllers => { :registrations => "users/registrations" }
  # mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
  # mount Piggybak::Engine => '/checkout', :as => 'piggybak'

  match 'dashboard', :to => 'static_pages#dashboard'
  # match 'article_index', :to => 'articles#article_index'
  # match "users/:id/update", to: "users#update"

  
  root :to => "pages#show", :id => 'home'


end