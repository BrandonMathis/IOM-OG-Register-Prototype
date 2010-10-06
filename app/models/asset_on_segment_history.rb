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
  
  def install(a)
    time = get_time
    self.update_attributes(:start => time)
    self.update_attributes(:logged_asset => LoggedAsset.create(
                                                    :g_u_i_d => a.g_u_i_d, 
                                                    :tag => a.tag,
                                                    :i_d_in_info_source => a.i_d_in_info_source,
                                                    :last_edited => a.last_edited,
                                                    :status => "1"))
    assets << a
    self.save
  end
  
  def self.field_names
    super + [:start, :end]
  end
  
  def self.attribute_names
    super + [:start, :end]
  end
  
  def uninstall()
    time = get_time
    self.update_attributes(:end => time, :last_edited => time)
    self.save
  end
  
  def destroy
    LoggedAsset.find_by_guid(logged_asset.guid).destroy if logged_asset
    super
  end
  
  def dup_entity (options = {})
    entity = super(options)
    entity.update_attributes(:start => self.send(:start))
    entity.update_attributes(:end => self.send(:end))
    
    entity.logged_asset = self.logged_asset if logged_asset
    assets.each{ |a| entity.assets << a if a}
    entity.save
    return entity
  end
  
  def build_xml(builder)
    super(builder)
    #builder.Asset {|b| self.logged_asset.build_xml(b)} if logged_asset
    #builder.Segment {|b| self.segment.build_xml(b)} if segment
    assets.each do |asset|
      builder.Asset {|b| asset.build_xml(b)} if asset
    end
    builder.Start self.start if start
    builder.End self.end if self.end
  end

end