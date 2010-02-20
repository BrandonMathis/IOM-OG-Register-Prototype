ActionController::Routing::Routes.draw do |map|

  map.resources :topologies
  map.resources :segments
  map.resources :assets
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
