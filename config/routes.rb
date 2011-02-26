ActionController::Routing::Routes.draw do |map|
  map.resources :predict_total_scores

  map.resources :results

  map.resources :spectators, :collection => {:result => :get}
  map.resources :predicitions, :collection => {:predict => :get, :calculate_match_result => :get}
  map.resources :entries
  map.resources :categories, :has_many => ['entries', 'matches']
  map.resources :teams

  map.resources :contests, :has_many => ['matches', 'posts']
  #map.resources :post, :has_many => 'matches', :through => :contest
  #map.resources :contests,  :collection => { :joinpublic_contest => :get } 
  
  map.root :controller => 'contests', :action => 'dashboard'
  #map.root :controller => 'contests'
  
  map.connect '/callback', :controller => 'engagements', :action => 'callback'
  map.connect '/posts/show', :controller => 'posts', :action => 'show',  :conditions => { :method => :get }
  map.connect '/posts/send_invites', :controller => 'posts', :action => 'send_invites'
  map.connect '/posts/plaxo', :controller => 'posts', :action => 'plaxo'
  map.connect '/users/groups', :controller => 'users', :action => 'groups',  :conditions => { :method => :get }
  map.resources :comments, :collection => {:set_comment_body => :post}
  map.resources :users, :collection => {:activate => :post, :resendnewactivation => :get, :resendactivation => :post, :display_profile => :get}
  map.resources :posts, :has_many => 'comments'
  map.resources :engagements, :collection => { :get_followers => :get, :resend_invite => :post, :get_auth_from_twitter => :get, :join_conversation_member_not_logged_in => :get, :join_conversation_facebox => :get, :join_conversation_non_member => :get }
  map.resources :user_sessions
  map.resources :password_resets
  map.resources :shared_posts
  map.resources :experiences, :collection => { :capture_experience => :get }
  map.resources :contacts, :collection => {:migrate_existing_contacts => :get}
  map.resources :matches
  
  #map.resources :groups, :collection => { :add_contact_to_groups => :get}

  map.about "about", :controller => 'posts', :action => 'about'
  map.privacy "privacy", :controller => 'posts', :action => 'privacy'
  map.blog "blog", :controller => 'posts', :action => 'blog'
  map.help "help", :controller => 'posts', :action => 'help'
  map.contact "contact", :controller => 'posts', :action => 'contact'
  map.disclaimer "disclaimer", :controller => 'posts', :action => 'disclaimer'
  map.login "login",   :controller => 'user_sessions', :action => 'new'
  map.logout "logout", :controller => 'user_sessions', :action => 'destroy'
  map.admin "admin", :controller => 'posts', :action => 'admin'
  map.how_to "how_to", :controller => 'contests', :action => 'how_to'
  map.world_cup "world_cup", :controller => 'posts', :action => "world_cup"
  map.prize "prizes", :controller => 'posts', :action => "prize"
  map.redeem_credits "redeem_credits", :controller => 'posts', :action => "redeem_credits"
    
  
  #map.join_public_contest "join_public_contest", :controller => 'contests', :action => 'join_public_contest'

  
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate' 
  map.auth_start '/authorize', :controller => 'spectators', :action => 'fb_authorize'
  map.auth_callback '/authorize/callback', :controller => 'spectators', :action => 'fb_callback'
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
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  map.error ':controllername',  :controller => 'posts', :action => '404'
  map.connect '*path' , :controller => 'posts', :action => '404'

end
