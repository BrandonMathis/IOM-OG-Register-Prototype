class Asset < MonitoredObject
  has_one :manufacturer, :xml_element => "Manufacturer"
  has_one :model, :xml_element => "Model"
  belongs_to_related :asset_on_segment_history
  has_one :valid_network, :xml_element => "ValidNetwork"
  field :serial_number
                    
  named_scope :topologies, where("type.g_u_i_d" => "a62a6cdb-ca56-4b2b-90aa-fafac73caa33")
  named_scope :serialized, where.not_in("type.g_u_i_d" => ["a62a6cdb-ca56-4b2b-90aa-fafac73caa33"])

  delegate :network, :to => :valid_network
  
  before_save :generate_name, :default_model
  
  def default_model
    self.model = Model.undetermined unless self.model
  end
  
  # Would be nice to have this so GUIDs can be validated but throws an error when 'rake test' is run
  # validates_format_of :g_u_i_d, 
  #                    :with => /^(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$/
  
  # KeysetTS
  # Will query and give an array of all uninstalled assets based on if the asset has a
  # history or if it has a history with a set end time
  def self.uninstalled
    assets = Asset.all()
    uninstalled = Array.new()
    assets.each do |a|
      asset = Asset.find_by_guid(a.g_u_i_d)
      uninstalled << asset if asset.asset_on_segment_history.nil? || !asset.asset_on_segment_history.end.nil?
    end
    return uninstalled
  end
  
  def self.field_names
    super + [:serial_number]
  end
  
  def self.attribute_names
    super + [:serial_number]
  end
  
  def segment
    return asset_on_segment_history.segment
  end
  
  def entry_edge=(object)
    self.entry_edges.clear
    self.entry_edges << object
  end

  def entry_edge
    self.entry_edges.first
  end

  def entry_edges=(array)
    ensure_network
    self.network.entry_edges = array
  end

  def entry_edges
    ensure_network
    self.network.entry_edges
  end

  def ensure_valid_network
    if valid_network.nil?
      self.build_valid_network(:tag => "#{self.tag} Asset Config Network")
    end
  end

  def ensure_network
    ensure_valid_network
    if network.nil?
      valid_network.build_network(:tag => "#{self.tag} View")
    end
  end
    
  # Custom actions to be executes when value for asset_on_segment_history (AOSH) is changed
  # However, this method of modifying the AOSH is undersired. If an uninstall or install is
  # to be performed it should be done so using mongoid to update the segment's installed asset
  #   - Segment.update_attributes(:install_asset_id => @asset.g_u_i_d)
  def asset_on_segment_history_with_mystuff=(asset_on_segment_history_to_assign)
    self.asset_on_segment_history_with_observer=(asset_on_segment_history_to_assign)
    self.asset_on_segment_history_with_blanking=(asset_on_segment_history_to_assign)
    self.asset_on_segment_history_without_mystuff=(asset_on_segment_history_to_assign)
  end

  alias_method_chain :asset_on_segment_history=, :mystuff
  
  # Generate a remove event if the AOSH has a not nil value that is changed
  #
  # Generate an install event if the AOSH is nil and is assigned a value unless that
  # value is null
  def asset_on_segment_history_with_observer=(asset_on_segment_history_to_assign)
    if self.asset_on_segment_history
      AssetObserver.remove(self, self.asset_on_segment_history)
    end
    unless asset_on_segment_history_to_assign.nil?
      AssetObserver.install(self, asset_on_segment_history_to_assign) unless asset_on_segment_history_to_assign.nil?
    end
    # self.asset_on_segment_history_without_observer=(asset_on_segment_history_to_assign)
  end
  
  # Set the AOSH_id to nil if we are trying to set the AOSH to nil
  def asset_on_segment_history_with_blanking=(asset_on_segment_history_to_assign)
    if asset_on_segment_history_to_assign.nil?
      self.asset_on_segment_history_id = nil
    end
    # self.asset_on_segment_history_without_blanking=(asset_on_segment_history_to_assign)
  end

  def build_xml(builder)
    super(builder)
    builder.tag!(:serialNumber, self.serial_number) unless self.serial_number.blank?
    builder.Model { |b| model.build_xml(b) } if model
    builder.Manufacturer { |b| manufacturer.build_xml(b) } if manufacturer
  end

  
  def dup_entity (options ={})
    entity = super(options)
    entity.update_attributes(:serial_number => self.send(:serial_number))
    
    entity.manufacturer = self.manufacturer.dup_entity(options) if manufacturer
    entity.model = self.model.dup_entity(options) if model
    entity.valid_network = self.valid_network.dup_entity(options) if valid_network      
    entity.save
    return entity
  end
  
  def destroy
    ValidNetwork.find_by_guid(valid_network.guid).destroy if valid_network
    super
  end
  
  private 
    def generate_name
      self.name = "Asset: " << self.g_u_i_d if name.blank?
    end
end