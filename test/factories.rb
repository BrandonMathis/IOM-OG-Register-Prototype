Factory.sequence(:i_d_in_info_source) { |i| "#{i}" }

def ccom_entity_fields(factory)
  factory.i_d_in_info_source { Factory.next :i_d_in_info_source }
end

Factory.define(:ccom_entity) do |f|
  ccom_entity_fields(f)
end

Factory.define(:ccom_object) do |f|
  ccom_entity_fields(f)
end

Factory.define(:type) do |f|
  ccom_entity_fields(f)
  f.sequence(:name) { |i| "Object Type #{i}" }
end

Factory.define(:attribute_type) do |f|
  ccom_entity_fields(f)
  f.sequence(:name) { |i| "Attribute Type #{i}" }
end

Factory.define(:object_datum) do |f|
  ccom_entity_fields(f)
  f.data "5"
  f.attribute_type { |a| a.association(:attribute_type) }
end

Factory.define(:eng_unit_type) do |f|
  ccom_entity_fields(f)
  f.sequence(:name) { |i| "Engineering Unit Type #{i}" }
end

Factory.define(:meas_location) do |f|
  ccom_entity_fields(f)
  f.sequence(:tag) { |i| "meas-location-#{i}" }
  f.sequence(:name) { |i| "Meas Location #{i}" }
  f.type { |a| a.association(:type) }
  f.association :default_eng_unit_type, :factory => :eng_unit_type
end

Factory.define(:segment) do |f|
  ccom_entity_fields(f)
  f.sequence(:name) { |i| "Segment #{i}" }
end

Factory.define(:asset_on_segment_history) do |f|
  ccom_entity_fields(f)
  f.sequence(:name) { |i| "AssetOnSegmentHistory #{i}"}
end

Factory.define(:network_connection) do |f|
  ccom_entity_fields(f)
  f.association :source, :factory => :segment
  f.association :target, :factory => :segment
  f.sequence(:order) { |i| i }
end

Factory.define(:network) do |f|
  ccom_entity_fields(f)
  f.sequence(:name) { |i| "Network #{i}" }
end

Factory.define(:valid_network) do |f|
  ccom_entity_fields(f)
  f.association :network, :factory => :network
end

Factory.define(:manufacturer) do |f|
  ccom_entity_fields(f)
  f.sequence(:tag) { |i| "manufacturer-#{i}" }
  f.sequence(:name) { |i| "Manufacturer #{i}" }
end

Factory.define(:model) do |f|
  ccom_entity_fields(f)
  f.sequence(:tag) { |i| "model-#{i}" }
  f.sequence(:name) { |i| "Model #{i}" }
  f.sequence(:product_family) { |i| "Z40#{i}" }
  f.sequence(:product_family_member) do |i| 
    char = ("A".."Z").to_a[i%26]
    prefix = (i > 26) ? ("A".."Z").to_a[i/26 -1 ] : ""
    prefix + char
  end
  f.sequence(:product_family_member_revision) { |i| "#{i}" }
  f.sequence(:part_number) { |i| "304823401-3442#{i}" }
end

Factory.define(:asset) do |f|
  ccom_entity_fields(f)
  f.sequence(:tag) { |i| "asset-#{i}" }
  f.sequence(:name) { |i| "Asset #{i}" }
end

Factory.define(:topology_type, :parent => :type) do |f|
  f.g_u_i_d "a62a6cdb-ca56-4b2b-90aa-fafac73caa33"
end

Factory.define(:serialized_asset, :parent => :asset) do |f|
end

Factory.define(:topology_asset, :parent => :asset) do |f|
  f.association :type, :factory => :topology_type
end

Factory.define(:actual_event) do |f|
  ccom_entity_fields(f)
end

Factory.define(:info_collection) do |f|
  ccom_entity_fields(f)
end

Factory.define(:enterprise) do |f|
  ccom_entity_fields(f)
end

Factory.define(:site) do |f|
  ccom_entity_fields(f)
end
