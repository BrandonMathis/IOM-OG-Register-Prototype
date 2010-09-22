class Manufacturer < CcomEntity
  has_one :type, :xml_element => :type
end
