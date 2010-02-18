class Asset < MonitoredObject
  has_one :manufacturer
  has_one :model
  has_one :segment
  has_one :asset_config_network
  field :serial_number

  def segment_with_observer=(segment_to_assign)
    if self.segment
      AssetObserver.remove(self, self.segment)
    end
    unless segment_to_assign.nil?
      AssetObserver.install(self, segment_to_assign) unless segment_to_assign.nil?
    end
    self.segment_without_observer=(segment_to_assign)
  end

  alias_method_chain :segment=, :observer

end
