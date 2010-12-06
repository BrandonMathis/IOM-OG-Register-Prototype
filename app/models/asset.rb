class Asset < MonitoredObject
  has_one :manufacturer, :xml_element => "Manufacturer"
  has_one :model, :xml_element => "Model"
  belongs_to_related :asset_on_segment_history
  has_one :valid_network, :xml_element => "ValidNetwork"
  field :serial_number
                    
  named_scope :topologies, where("object_type.g_u_i_d" => "a62a6cdb-ca56-4b2b-90aa-fafac73caa33")
  named_scope :serialized, where.not_in("object_type.g_u_i_d" => ["a62a6cdb-ca56-4b2b-90aa-fafac73caa33"])

  delegate :network, :to => :valid_network
  
  before_save :set_default_type
    
  # Defines that a serial_number field must exsit for an Asset  
  def self.additional_fields; [:serial_number] end
  
  # Gives all aditional fields for and instance of Asset
  def additional_fields; self.class.additional_fields end
  
  # Give all default and additional attributes for Asset
  def self.attribute_names; super + additional_fields end
  
  # Give all default and additional fields for the Asset table in the database
  def self.field_names; super + additional_fields end
  
  # Give list of editable attributes
  def editable_attribute_names; super + additional_fields end
  
  # Will query and give an array of all assets not installed on a Segment
  #
  # This is based on if the asset has an attached AssetOnSegmentHistory
  # or if it has a history with a set end time
  def self.uninstalled
    assets = Asset.all()
    uninstalled = Array.new()
    assets.each do |a|
      asset = Asset.find_by_guid(a.g_u_i_d)
      uninstalled << asset if asset.asset_on_segment_history.nil? || asset.asset_on_segment_history.end
    end
    return uninstalled
  end
  
  # Gives the segment this Asset is installed on. Returns nil
  # if this Asset is not installed on a Segment
  def segment
    return asset_on_segment_history.segment rescue nil
  end
  
  # Set the value of the entry edges to a single edge for an asset
  def entry_edge=(object)
    self.entry_edges.clear
    self.entry_edges << object
  end

  # Get the first entry edge related to an asset
  def entry_edge
    self.entry_edges.first
  end
  
  # Set an array of edges for an asset
  def entry_edges=(array)
    ensure_network
    self.network.entry_edges = array
  end
  
  # Get array of entry_edges associated to an asset
  def entry_edges
    ensure_network
    self.network.entry_edges
  end
  
  # Ensure that the asset has a ValidNetwork related to it.
  #
  # <tt>Will build a valid network if there is none</tt>
  def ensure_valid_network
    if valid_network.nil?
      self.build_valid_network(:tag => "#{self.tag} Asset Config Network")
    end
  end
  
  # Ensure that the asset has a network related to it (within the ValidNetwork)
  #
  # <tt>Will build a network if there is none</tt>
  def ensure_network
    ensure_valid_network
    if network.nil?
      valid_network.build_network(:tag => "#{self.tag} View")
    end
  end
    
  # Custom actions to be executed when the asset's AssetOnSegmentHistory (AOSH) is changed
  # However, this method of modifying the AOSH is undersired. If an uninstall or install is
  # to be performed it should be done so using mongoid to update the segment's installed asset
  #   # this calls the Segment's install_asset_id method 
  #   Segment.update_attributes(:install_asset_id => @asset.g_u_i_d) 
  def asset_on_segment_history_with_mystuff=(asset_on_segment_history_to_assign)
    self.asset_on_segment_history_with_observer=(asset_on_segment_history_to_assign)
    self.asset_on_segment_history_with_blanking=(asset_on_segment_history_to_assign)
    self.asset_on_segment_history_without_mystuff=(asset_on_segment_history_to_assign)
  end

  alias_method_chain :asset_on_segment_history=, :mystuff
  
  # Generate a remove event if the AssetOnSegmentHistory a value that is changed 
  # (AssetOnSegmentHistory is not nill)
  #
  # Generate an install event if the asset's AssetOnSegmentHistory is nil and
  # assigned a value unless that value is nill
  def asset_on_segment_history_with_observer=(asset_on_segment_history_to_assign)
    if self.asset_on_segment_history
      AssetObserver.remove(self, self.asset_on_segment_history)
    end
    unless asset_on_segment_history_to_assign.nil?
      AssetObserver.install(self, asset_on_segment_history_to_assign) unless asset_on_segment_history_to_assign.nil?
    end
    # self.asset_on_segment_history_without_observer=(asset_on_segment_history_to_assign)
  end
  
  # Set's the asset's AssetOnSegmentHistory to nill
  def asset_on_segment_history_with_blanking=(asset_on_segment_history_to_assign)
    if asset_on_segment_history_to_assign.nil?
      self.asset_on_segment_history_id = nil
    end
    # self.asset_on_segment_history_without_blanking=(asset_on_segment_history_to_assign)
  end

  # XML builder for an Asset (called from to_xml)
  def build_xml(builder)
    super(builder)
    builder.ValidNetwork { |b| valid_network.build_xml(b) } if valid_network
    builder.Model { |b| model.build_xml(b) } if model
    builder.Manufacturer { |b| manufacturer.build_xml(b) } if manufacturer
  end

  # Will duplicated the Asset and all related entities
  def dup_entity (options ={})
    entity = super(options)
    entity.update_attributes(:serial_number => self.send(:serial_number))
    
    entity.manufacturer = self.manufacturer.dup_entity(options) if manufacturer
    entity.model = self.model.dup_entity(options) if model
    entity.valid_network = self.valid_network.dup_entity(options) if valid_network      
    entity.save
    return entity
  end
  
  # Will destroy the Asset and all related entities
  def destroy
    ValidNetwork.find_by_guid(valid_network.guid).destroy if valid_network && ValidNetwork.find_by_guid(valid_network.guid)
    super
  end
  
  private
  def set_default_type
    self.object_type ||= ObjectType.undetermined
  end
end