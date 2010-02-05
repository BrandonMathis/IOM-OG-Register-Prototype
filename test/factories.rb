Factory.sequence(:guid) { |i| "#{Time.now.to_i}#{i}" }
Factory.sequence(:id_in_source) { |i| "#{i}" }

Factory.define(:ccom_object) do |f|
  f.guid { Factory.next :guid }
  f.id_in_source { Factory.next :id_in_source }
  f.source_id "exxon.com/uehm/ramp/V1.0"
end

Factory.define(:object_type, :parent => :ccom_object) do |f|
  f.sequence(:user_name) { |i| "Object Type #{i}" }
end

Factory.define(:attribute_type, :parent => :ccom_object) do |f|
  f.sequence(:user_name) { |i| "Attribute Type #{i}" }
end

