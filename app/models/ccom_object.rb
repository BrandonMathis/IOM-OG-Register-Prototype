class CcomObject < CcomEntity

  has_one :type, :xml_element => "Type"
  before_save :generate_last_edited

  def build_xml(builder)
    super(builder)
    builder.Type { |b| self.type.build_xml(b) } if type
  end
  
  private
  def generate_last_edited
    self.last_edited = Time.now.strftime('%Y-%m-%dT%H:%M:%S') if last_edited.blank?
  end  
end
