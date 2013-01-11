PmdWinter::Application.routes.draw do

  # manual subdomain checking as nginx/apache diagree.
  # constraints lambda {|req| return 'data' == req.host.split('.').first } do
  #   mount PublishMyData::Engine => "/"
  # end

  constraints lambda {|req| return 'data' != req.host.split('.').first } do

    devise_for :users, :controllers => { :registrations => "users" }

    devise_scope :user do
      match '/users/zones' => 'users#update_zones', :via => :put
    end

    root :to => 'reports#index'

    match '/about' => "home#about"
    match '/help' => "home#help"

    match '/reports/tags' => "reports#tags", :as => 'reports_tags'
    match '/server_localtime' => "reports#localtime", :as => 'server_localtime'

    resources :reports do
      member do
        put "close"
      end

      resources :comments, :only => [:create, :destroy]
    end



    resources :zones

    #http://techoctave.com/c7/posts/36-rails-3-0-rescue-from-routing-error-solution
    match '*a', :to => 'errors#routing'
  end

end
