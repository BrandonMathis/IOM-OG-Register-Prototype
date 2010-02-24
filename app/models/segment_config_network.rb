class SegmentConfigNetwork < CcomObject
  has_one :associated_network, :class_name => "Network"
end
