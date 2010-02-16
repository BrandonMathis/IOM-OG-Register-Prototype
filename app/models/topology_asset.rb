class TopologyAsset < Asset

  def network=(object)
    self.asset_config_network ||= AssetConfigNetwork.new
    asset_config_network.associated_network = object
  end

  def network
    self.asset_config_network ||= AssetConfigNetwork.new
    asset_config_network.associated_network
  end
end
