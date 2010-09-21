# KeysetTS added class [28 July 2010 13:48]
class AssetOnSegmentHistory < CcomEntity
  # A has_many_related relationship is used here because has_one_related throws a strange error. 
  # It would be nice to fix this
  belongs_to_related :segment
  has_many_related :assets, :class_name => "Asset", :xml_element => "Asset"
  has_one :logged_asset
  field :start          #when the asset was placed onto the segment
  field :end            #when the asset was removed from the segment
  
  before_create :generate_guid
  
  def install(a)
    self.update_attributes(:start => Time.now.strftime('%Y-%m-%dT%H:%M:%S'))
    self.update_attributes(:logged_asset => LoggedAsset.create(
                                                    :g_u_i_d => a.g_u_i_d, 
                                                    :tag => a.tag,
                                                    :i_d_in_info_source => a.i_d_in_info_source,
                                                    :last_edited => a.last_edited,
                                                    :status => "1"))
    assets << a
    self.save
  end
  
  def uninstall()
    self.update_attributes(:end => Time.now.strftime('%Y-%m-%dT%H:%M:%S'))
    self.save
  end
  
  def dup_entity (options = {})
    entity = super(options)
    entity.update_attributes(:start => self.send(:start))
    entity.update_attribute(:end => self.send(:end))
    
    entity.logged_asset = self.logged_asset if logged_asset
    assets.each{ |a| entity.assets << a }
    entity.save
    return entity
  end
  
  def build_xml(builder)
    builder.Asset {|b| self.logged_asset.build_xml(b)} if logged_asset
    builder.Segment {|b| self.segment.build_xml(b)} if segment
  end
end