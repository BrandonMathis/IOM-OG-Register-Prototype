Factory.sequence(:guid) { |i| "#{Time.now.to_i}#{i}" }
Factory.sequence(:id_in_source) { |i| "#{i}" }

def ccom_entity_fields(factory)
  factory.guid { Factory.next :guid }
  factory.id_in_source { Factory.next :id_in_source }
  factory.source_id "exxon.com/uehm/ramp/V1.0"
end

Factory.define(:ccom_entity) do |f|
  ccom_entity_fields(f)
end

Factory.define(:ccom_object) do |f|
  ccom_entity_fields(f)
end

Factory.define(:object_type) do |f|
  ccom_entity_fields(f)
  f.sequence(:user_name) { |i| "Object Type #{i}" }
end

Factory.define(:attribute_type) do |f|
  ccom_entity_fields(f)
  f.sequence(:user_name) { |i| "Attribute Type #{i}" }
end

Factory.define(:object_datum) do |f|
  ccom_entity_fields(f)
  f.data "5"
  f.attribute_type { |a| a.association(:attribute_type) }
end

Factory.define(:eng_unit_type) do |f|
  ccom_entity_fields(f)
  f.sequence(:user_name) { |i| "Engineering Unit Type #{i}" }
end

Factory.define(:meas_location) do |f|
  ccom_entity_fields(f)
  f.sequence(:user_tag) { |i| "meas-location-#{i}" }
  f.sequence(:user_name) { |i| "Meas Location #{i}" }
  f.object_type { |a| a.association(:object_type) }
  f.association :default_eng_unit_type, :factory => :eng_unit_type
end

Factory.define(:segment) do |f|
  ccom_entity_fields(f)
  f.sequence(:user_name) { |i| "Segment #{i}" }
end

Factory.define(:network_connection) do |f|
  ccom_entity_fields(f)
  f.association :source, :factory => :segment
  f.sequence(:ordering_seq) { |i| i }
end

Factory.define(:network) do |f|
  ccom_entity_fields(f)
  f.sequence(:user_name) { |i| "Network #{i}" }
end

Factory.define(:asset_config_network) do |f|
  ccom_entity_fields(f)
  f.association :associated_network, :factory => :network
end

Factory.define(:manufacturer) do |f|
  ccom_entity_fields(f)
  f.sequence(:user_tag) { |i| "manufacturer-#{i}" }
  f.sequence(:user_name) { |i| "Manufacturer #{i}" }
end

Factory.define(:model) do |f|
  ccom_entity_fields(f)
  f.sequence(:user_tag) { |i| "model-#{i}" }
  f.sequence(:user_name) { |i| "Model #{i}" }
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
  f.sequence(:user_tag) { |i| "asset-#{i}" }
  f.sequence(:user_name) { |i| "Asset #{i}" }
end

Factory.define(:event) do |f|
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
