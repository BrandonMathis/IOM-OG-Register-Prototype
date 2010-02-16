class TopologyAsset < Asset

  def functional_location=(object)
    self.network.entry_points << object
  end

  def functional_location
    self.network.entry_points.first
  end

  protected

  def network=(object)
    self.asset_config_network ||= AssetConfigNetwork.new
    asset_config_network.associated_network = object
  end

  def network
    self.asset_config_network ||= AssetConfigNetwork.new
    if asset_config_network.associated_network.nil? 
      asset_config_network.build_associated_network(:user_tag => self.user_tag, :user_name => self.user_name)
    end
    asset_config_network.associated_network
  end
end
