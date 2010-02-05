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

Factory.define(:object_data) do |f|
  ccom_entity_fields(f)
  f.data "5"
  f.attribute_type { |a| a.association(:attribute_type) }
end
