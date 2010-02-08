class Asset < MonitoredObject
  has_one :manufacturer
  has_one :model
  field :serial_number
end
