Factory.define(:ccom_object) do |f|
  f.guid { Factory.next :guid }
  f.id_in_source { Factory.next :id_in_source }
  f.source_id "exxon.com/uehm/ramp/V1.0"
end
