DnsApp::Application.routes.draw do
  resources :domain_names, :path => 'dns'
  resources :reverse_domain_names, :path => 'reversedns',
                                   :only => [:index, :show]
  
  namespace "admin" do
    resources :privileged_users, :path => 'users' do
      member do
        get 'edit_privileges'
        put 'update_privileges'
      end
    end
    resources :domain_names, :path => 'dns'
    resources :cnames, :path => 'alias'
    resources :unauthorized_names, :path => 'unames'
  end

  resources :sessions, :only => [:new, :create, :destroy]

  match '/signin',  :to => 'sessions#new'
  match '/signout', :to => 'sessions#destroy'

  

  root :to => 'pages#home'
end
