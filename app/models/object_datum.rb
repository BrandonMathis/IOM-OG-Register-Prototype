class ObjectDatum < CcomEntity
  has_one :attribute_type
  has_one :eng_unit_type
  field :data
end
