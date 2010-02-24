class AssetConfigNetwork < CcomObject
  has_one :associated_network, :class_name => "Network", :xml_prefix => :blank
end
