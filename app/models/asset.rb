class Asset < MonitoredObject
  has_one :manufacturer
  has_one :model
  belongs_to_related :segment
  has_one :asset_config_network, :xml_element => "hasAssetConfigNetwork"
  field :serial_number

  named_scope :uninstalled, where(:segment_id => nil)

  delegate :associated_network, :to => :asset_config_network

  def entry_points=(array)
    ensure_associated_network
    self.associated_network.entry_points = array
  end

  def entry_points
    ensure_associated_network
    self.associated_network.entry_points
  end

  def ensure_asset_config_network
    if asset_config_network.nil?
      self.build_asset_config_network(:user_tag => "#{self.user_tag} Asset Config Network")
    end    
  end

  def ensure_associated_network
    ensure_asset_config_network
    if associated_network.nil?
      asset_config_network.build_associated_network(:user_tag => "#{self.user_tag} View")
    end
  end

  def segment_with_mystuff=(segment_to_assign)
    self.segment_with_observer=(segment_to_assign)
    self.segment_with_blanking=(segment_to_assign)
    self.segment_without_mystuff=(segment_to_assign)
  end

  alias_method_chain :segment=, :mystuff

  def segment_with_observer=(segment_to_assign)
    if self.segment
      AssetObserver.remove(self, self.segment)
    end
    unless segment_to_assign.nil?
      AssetObserver.install(self, segment_to_assign) unless segment_to_assign.nil?
    end
    # self.segment_without_observer=(segment_to_assign)
  end

  def segment_with_blanking=(segment_to_assign)
    if segment_to_assign.nil?
      self.segment_id = nil
    end
    # self.segment_without_blanking=(segment_to_assign)
  end

end
