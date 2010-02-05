Factory.define(:object_type, :parent => :ccom_object) do |f|
  f.sequence(:user_name) { |i| "Object Type #{i}" }
end
