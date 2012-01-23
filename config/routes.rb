# encoding: utf-8

#Author: Johann-Michael THIEBAUT <johann.thiebaut@gmail.com>
#Routing structure of application

DnsApp::Application.routes.draw do
  
  #DNS Records routes
  resources :dns_records, :path => 'dns',
                          :only => :index

  resources :dns_soa_records, :path => 'dnssoa',
                              :only => [:index, :show]

  resources :dns_ns_records, :path => 'dnsns',
                             :only => [:index, :show]

  resources :dns_mx_records, :path => 'dnsmx',
                             :only => [:index, :show]

  resources :dns_a_records, :path => 'dnsa',
                            :only => [:index, :show]

  resources :dns_cname_records, :path => 'dnscname',
                                :only => [:index, :show]


  #Reverse DNS Records routes
  resources :reverse_dns_records, :path => 'rdns',
                                  :only => :index

  resources :reverse_dns_soa_records, :path => 'rdnssoa',
                                      :only => [:index, :show]

  resources :reverse_dns_ns_records, :path => 'rdnsns',
                                     :only => [:index, :show]

  resources :reverse_dns_ptr_records, :path => 'rdnsptr',
                                      :only => [:index, :show]


  #Zone élèves
  namespace "ze" do
    resources :dns_a_records, :path => 'dnsa'
  end

  #Admin namespace
  namespace "admin" do
    resources :privileged_users, :path => 'users' do
      member do
        get 'edit_privileges'
        put 'update_privileges'
      end
    end
    #resources :domain_names, :path => 'dns'
    #resources :cnames, :path => 'alias'
    resources :unauthorized_names, :path => 'unames'
    resources :zones, :path => 'unames'
  end

  #To log in and out
  resources :sessions, :only => [:new, :create, :destroy]

  match '/signin',  :to => 'sessions#new'
  match '/signout', :to => 'sessions#destroy'

  root :to => 'pages#home'
end
