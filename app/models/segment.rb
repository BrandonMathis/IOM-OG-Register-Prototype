class Segment < MonitoredObject
  has_many :meas_locations
  has_many_related :installed_assets, :class_name => "Asset"

  def install_asset_id; nil; end

  def install_asset_id=(asset_id)
    asset = Asset.find_by_guid(asset_id)
    AssetObserver.install(asset, self)
    installed_assets << asset
  end


  def build_xml(builder)
    super(builder)
    meas_locations.each do |m|
      builder.hasMeasLocation do |b|
        m.build_xml(b)
      end
    end
  end
end
