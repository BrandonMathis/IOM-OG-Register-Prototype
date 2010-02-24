class Segment < MonitoredObject
  has_one :segment_config_network, :xml_element => "hasSegmentConfigNetwork"
  has_many :meas_locations, :xml_element => "hasMeasLocation"
  has_many_related :installed_assets, :class_name => "Asset", :xml_element => "hasInstalledAsset"

  before_save :save_assets
  attr_accessor :assets_to_save
  def assets_to_save; @assets_to_save ||= []; end

  def install_asset_id; nil; end

  def install_asset_id=(asset_id)
    asset = Asset.find_by_guid(asset_id)
    AssetObserver.install(asset, self)
    installed_assets << asset
  end

  def delete_asset_id=(asset_id)
    if asset = installed_assets.detect {|asset| asset.guid == asset_id }
      asset.segment = nil 
      assets_to_save << asset
    end
  end

  def build_xml(builder)
    super(builder)
    builder.hasSegmentConfigNetwork {|b| segment_config_network.build_xml(b) } if segment_config_network
    meas_locations.each do |m|
      builder.hasMeasLocation do |b|
        m.build_xml(b)
      end
    end
  end

  protected

  def save_assets
    assets_to_save.each { |a| a.save }
    assets_to_save = []
  end
end
