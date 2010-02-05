class MeasLocation < CcomObjectWthEvents
  has_one :default_eng_unit_type, :name => :eng_unit_type
  has_one :object_type
  has_many :object_data, :name => :object_data
end
