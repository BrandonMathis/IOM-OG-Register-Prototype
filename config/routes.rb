ActionController::Routing::Routes.draw do |map|

  map.resources :topologies
  map.resources :segments
  map.resources :assets
  map.resources :ccom_data

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  map.root :controller => "ccom_data"
end
