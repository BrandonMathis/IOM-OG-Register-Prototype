# A LoggedAsset is an Asset stored in the Database
# but is not part of the Active Registry. This LoggedAsset
# is used as a reference Asset for AssetOnSegmentHistory
# entities. So, if an Asset is modified or deleted this
# log of the Asset will keep the data the same as it was
# when the Asset was installed or removed from a Segment
class LoggedAsset < CcomEntity
  def generate_last_edited
    super if self.last_edited.blank?
  end
end