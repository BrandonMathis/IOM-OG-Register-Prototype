ActionController::Routing::Routes.draw do |map|
  map.resources :databases


  map.resources :topologies
  map.resources :segments, :as => "Segment"
  map.resources :assets, :as => "Asset"
  map.resources :ccom_data, :as => "registry"
  map.resources :ccom
  map.resources :ccom_rest, :as => "CCOMData"
  map.resources :type, :as => "Type"
  map.resources :eng_unit_type, :as => "UnitType"
  map.resources :manufacturer, :as => "Manufacturer"
  map.resources :meas_location, :as => "MeasurementLocation"
  map.resources :model, :as => "Model"
  map.resources :network, :as => "Network"
  map.resources :object_datum, :as => "Attribute"
  map.resources :site, :as => "ControlledSite"
  map.resources :valid_network, :as => "ValidNetwork"
  map.resources :enterprise, :as => "Enterprise"
  map.resources :network_connection, :as => "EntryEdge"
  map.resources :successor, :as => "Successor"
  map.resources :asset_on_segment_history, :as => "AssetOnSegmentHistory"
  map.resources :users
  
  map.delete_ccom_data 'db/clear', :controller => "ccom_data", :action => "delete_all"

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
  map.resources :test_client
  map.root :controller => "ccom_data"
end
