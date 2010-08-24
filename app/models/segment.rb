class Segment < MonitoredObject
  has_one :segment_config_network, :xml_element => "ValidNetwork"
  has_many :meas_locations, :xml_element => "MeasurementLocation"
  has_many_related :asset_on_segment_historys, :class_name => "AssetOnSegmentHistory", :xml_element => "AssetOnSegmentHistory"
  has_many :installed_assets, :class_name => "Asset"
  # [28 July 2010] Removed occurance of hast_many :installed_assets to be replaced with method installed_assets
  
  def entry_edges
    segment_config_network.network.entry_edges rescue []
  end

  before_save :save_assets
  attr_accessor :assets_to_save
  def assets_to_save; @assets_to_save ||= []; end

  def install_asset_id; nil; end

  # Added to decrease appwide change. installed_assets will performe just as though the 
  # information for installed assets is being held here on the segment when it is actually
  # housed inside the AssetOnSegmentHistory
  # NOTE:
  #   The history's end value must not be set in order for related asset to be considered installed
  def installed_assets()
    installed = Array.new()
    asset_on_segment_historys.each do |hist|
      if !hist.assets.first.nil?
        asset = Asset.find_by_guid(hist.assets.first.g_u_i_d)
        installed << asset if asset.asset_on_segment_history.end.nil?
      end
    end
    return installed
  end
  
  # KeysetTS
  # Modified to fit the addition of an AssetOnSegmentHistory element to CCOM
  # This elemet holds the Asset's start and end time for being installed on the segment
  # installing a new asset involves creating a new history and setting <Start> to Time.now
  #
  # Creates a new install history which loggs the asset placed on this segment
  def install_asset_id=(asset_id)
    asset = Asset.find_by_guid(asset_id)
    hist = AssetOnSegmentHistory.create()
    asset.asset_on_segment_history = nil
    hist.install(asset)
    asset.save
    asset_on_segment_historys <<  hist
    AssetObserver.install(asset, self)
  end

  def delete_asset_id=(asset_id)
    if asset = installed_assets.detect {|asset| asset.g_u_i_d == asset_id }
      hist = asset.asset_on_segment_history
      hist.uninstall()
      asset.asset_on_segment_history_id = nil
      assets_to_save << asset
      AssetObserver.remove(asset, self)
    end
  end

  def build_xml(builder)
    super(builder)
    builder.ValidNetwork {|b| segment_config_network.build_xml(b) } if segment_config_network
    meas_locations.each do |m|
      builder.MeasurementLocation do |b|
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
