# KeysetTS added class [28 July 2010 13:48]
class AssetOnSegmentHistory < CcomObject
  # A has_many_related relationship is used here because has_one_related throws a strange error. 
  # It would be nice to fix this
  belongs_to_related :segment
  has_many_related :assets, :class_name => "Asset", :xml_element => "Asset"
  has_one :logged_asset
  field :start          #when the asset was placed onto the segment
  field :end            #when the asset was removed from the segment
  
  before_create :generate_guid
  
  # Defines that a start and end field must exsit for an AssetOnSegmentHistory  
  def self.additional_fields; [:start, :end] end
  
  # Gives all aditional fields for and instance of AssetOnSegmentHistory
  def additional_fields; self.class.additional_fields end
  
  # Give all default and additional attributes for AssetOnSegmentHistory
  def self.attribute_names; super + additional_fields end
  
  # Give all default and additional fields for the Asset table in the database
  def self.field_names; super + additional_fields end
  
  # Give list of editable attributes
  def editable_attribute_names; super + additional_fields end
 
  # Will modify this history to reflect the installation of an Asset
  # onto a Segment related to this history
  def install(a)
    time = CcomEntity.get_time
    self.update_attributes(:start => time)
    assets << a
    self.save
  end
  
  # Will modify this history to reflect the removal of an Asset
  # from the Segment related to this history
  def uninstall(a)
    time = CcomEntity.get_time
    self.update_attributes(:logged_asset => LoggedAsset.create(
                                                    :g_u_i_d => a.g_u_i_d, 
                                                    :tag => a.tag,
                                                    :name => a.name,
                                                    :i_d_in_info_source => a.i_d_in_info_source,
                                                    :last_edited => a.last_edited,
                                                    :status => "1"))
    self.update_attributes(:end => time, :last_edited => time)
    self.save
  end
  
  # Will destroy the AssetOnSegmentHistory and all related entities
  def destroy
    LoggedAsset.find_by_guid(logged_asset.guid).destroy if logged_asset && LoggedAsset.find_by_guid(logged_asset.guid)
    super
  end
  
  # Will duplicate the AssetOnSegmentHistory all all related entities
  def dup_entity (options = {})
    entity = super(options)
    entity.update_attributes(:start => self.send(:start))
    entity.update_attributes(:end => self.send(:end))
    
    entity.logged_asset = self.logged_asset if logged_asset
    assets.each{ |a| entity.assets << a if a}
    entity.save
    return entity
  end
  
  # XML builder for the AssetOnSegmentHistory
  def build_xml(builder)
    super(builder)
    builder.Asset {|b| self.logged_asset.build_xml(b)} if logged_asset && assets.blank?
    builder.Segment {|b| self.segment.build_basic_xml(b)} if segment
    assets.each do |asset|
      builder.Asset {|b| asset.build_xml(b)} if asset
    end
  end
end