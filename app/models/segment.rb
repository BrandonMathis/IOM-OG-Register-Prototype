class Segment < MonitoredObject
  has_one :segment_config_network, :class_name => "ValidNetwork", :xml_element => "ValidNetwork"
  has_many :meas_locations, :xml_element => "MeasurementLocation"
  has_many_related :asset_on_segment_historys, :class_name => "AssetOnSegmentHistory", :xml_element => "AssetOnSegmentHistory"
  has_many :installed_assets, :class_name => "Asset"
  # [28 July 2010] Removed occurance of hast_many :installed_assets to be replaced with method installed_assets
  
  def entry_edges
    segment_config_network.network.entry_edges rescue []
  end

  before_save :save_assets
  attr_accessor :assets_to_save

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
        installed << asset unless asset.asset_on_segment_history.nil?
      end
    end
    return installed
  end
  
  # KeysetTS
  # Modified to fit the addition of an AssetOnSegmentHistory (AOSH) element to CCOM
  # This elemet holds the Asset's start and end time for being installed on the segment
  # installing a new asset involves creating a new history and setting <Start> to Time.now
  #
  # AssetObserver then generates an install event to be caught by sinatra postback_server
  #
  # A copy of the asset is placed inside of logged_asset for future reference when we want
  # to see a history of all assets installed on the segment
  def install_asset_id=(asset_id)
    asset = Asset.find_by_guid(asset_id)
    hist = AssetOnSegmentHistory.create()
    asset_on_segment_historys <<  hist
    hist.install(asset)
    asset.save
    AssetObserver.install(asset, hist)
  end
  
  # KeysetTS
  # Modified to fith with the addition of AOSH element to CCOM
  # This will set an end time to the associated history followed by unlinking the
  # history from the asset
  # AssetObserver then generates a remove event to be caught by sinatra postback_server
  def delete_asset_id=(asset_id)
    if asset = installed_assets.detect {|asset| asset.g_u_i_d == asset_id }
      hist = asset.asset_on_segment_history
      hist.uninstall(asset)
      AssetObserver.remove(asset, hist)
      asset.asset_on_segment_history_id = nil
      assets_to_save << asset      
    end
  end
  
  # Will destroy the Segment and all related entities
  def destroy
    ValidNetwork.find_by_guid(segment_config_network.guid).destroy if segment_config_network &&ValidNetwork.find_by_guid(segment_config_network.guid)
    meas_locations.each {|mloc| MeasLocation.find_by_guid(mloc.guid).destroy if mloc && MeasLocation.find_by_guid(mloc.guid)}
    super
  end    

  # Will duplicated the Segment and all related entities
  def dup_entity(options = {})
    entity = super(options)
    entity.segment_config_network = self.segment_config_network if segment_config_network
    meas_locations.each { |mloc| entity.meas_locations << mloc.dup_entity(options) if mloc }
    asset_on_segment_historys.each { |hist| entity.hist << hist.dup_entity(options) if hist }
    installed_assets.each { |asset| entity.installed_assets << installed_assets.dup_entity(options) if installed_assets }
    entity.save
    return entity
  end
  
  # XML builder for the Segment
  def build_xml(builder)
    super(builder)
    builder.ValidNetwork {|b| segment_config_network.build_xml(b) } if segment_config_network
    asset_on_segment_historys.each do |aosh|
      builder.AssetOnSegmentHistory {|b| aosh.build_xml(b)} if aosh
    end
    meas_locations.each do |m|
      builder.MeasurementLocation do |b|
        m.build_xml(b)
      end
    end
  end

  protected
  def assets_to_save; @assets_to_save ||= []; end
  
  def save_assets
    assets_to_save.each { |a| a.save }
    assets_to_save = []
  end
end
