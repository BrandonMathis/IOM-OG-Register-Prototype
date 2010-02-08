class Asset < MonitoredObject
  has_one :manufacturer
  has_one :model
  has_one :asset_config_network
  field :serial_number
end
