ActionController::Routing::Routes.draw do |map|

  map.resources :topologies
  map.resources :segments
  map.resources :assets
  map.resources :ccom_data
  map.delete_ccom_data 'db/clear', :controller => "ccom_data", :action => "delete_all"

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  map.root :controller => "ccom_data"
end
