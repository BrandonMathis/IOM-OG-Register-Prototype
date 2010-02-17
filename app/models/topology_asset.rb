class TopologyAsset < Asset

  def entry_point=(object)
    ensure_associated_network
    self.associated_network.entry_points.clear
    self.associated_network.entry_points << object
  end

  def entry_point
    ensure_associated_network
    self.associated_network.entry_points.first
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

  delegate :associated_network, :to => :asset_config_network
end
