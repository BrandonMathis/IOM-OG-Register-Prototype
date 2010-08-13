class SegmentConfigNetwork < CcomObject
  has_one :network, :class_name => "Network", :xml_element => "Network"
end
