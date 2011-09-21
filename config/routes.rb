
ActionController::Routing::Routes.draw do |map|
  map.forgot_password '/forgot_password', :controller => 'forgot_passwords', :action => 'new'
  map.change_password '/change_password/:reset_code', :controller => 'forgot_passwords', :action => 'reset'
  map.resources :forgot_passwords


  map.resources :mypages, :collection => {:search => :get}
  map.resources :mypages, :member => {:delete_confirm => :get}

  map.resources :channels, :member=>{:update=> :post, :taggings => :get, :clear=> :get, :download => :get, :upload => :post} do |channel|
    channel.resources :taggings
    channel.resources :pages, :member=>{:update=> :post, :playpage=> :get, :layout=> :get ,:backimages => :get ,:addplayer=> :get ,:upload=> :post, :clear=> :get ,:up_down_ref => :get} do |page|
      page.resources :previews
      page.resources :players 
      page.resources :template_pages
      page.resources :contents, :member=>{:update=> :post, :preview=> :get, :drag=> :post ,:contentdelete=> :get,:contentseq => :post,:player_copy => :get,:player_paste => :get,:image_text_new => :get,:image_text_edit => :get}
    end
  end
  map.resources :index_messages, :member => {:enable => :put, :disable=>:put }
  map.resources :contents
  map.resources :pages
  map.resources :permissions
  map.resources :players, :member => {:enable => :put, :disable=>:put }
  map.resources :roles
  map.resource :session
  map.resources :users, :new=>{:deactivate=>:put}
  map.resources :users, :member => {:settings =>:get,  :delete_user=>:get}
  map.resources :users, :member => {:enable => :put } do |users|
    users.resources :permissions
  end
  map.resources :player_infos, :member=>{:update=> :post}
  map.resources :yamlmails
  map.resources :yamlmail_recieve
  map.resources :yaml_db_forms
  map.resources :user_property
  
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate'
  
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  
  map.search_engine '/search_engine', :controller => 'search_engine', :action => 'index'
  
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "welcome"

  map.connect "/remote/:channel_no", :controller => "remote"
  # See how all your routes lay out with "rake routes"
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
