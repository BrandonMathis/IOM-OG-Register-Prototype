# KeysetTS added class [28 July 2010 13:48]
class AssetOnSegmentHistory < CcomEntity
  # A has_many_related relationship is used here because has_one_related throws a strange error. 
  # It would be nice to fix this
  has_many_related :assets, :class_name => "Asset", :xml_element => "Asset"
  field :start          #when the asset was placed onto the segment
  field :end       #when the asset was removed from the segment
  
  def install(asset)
    self.update_attributes(:start => Time.now.to_s)
    self.save
    assets << asset
  end
  
  def uninstall(asset)
    self.update_attributes(:end => Time.now.to_s)
    self.save
    RAILS_DEFAULT_LOGGER.debug("time #{self.end}")
  end
  
end