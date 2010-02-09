class Asset < MonitoredObject
  has_one :manufacturer
  has_one :model
  has_one :installed_on_segment, :class_name => "Segment"
  has_one :asset_config_network
  field :serial_number
end
