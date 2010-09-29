class LoggedAsset < CcomEntity
  def generate_last_edited
    super if self.last_edited.blank?
  end
end