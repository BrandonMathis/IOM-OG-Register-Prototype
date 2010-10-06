ActionController::Routing::Routes.draw do |map|

  map.resources :topologies
  map.resources :segments, :as => "Segment"
  map.resources :assets, :as => "Asset"
  map.resources :ccom_data
  map.resources :ccom
  map.resources :ccom_rest
  map.resources :type, :as => "Type"
  map.delete_ccom_data 'db/clear', :controller => "ccom_data", :action => "delete_all"

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  map.root :controller => "ccom_data"
end
