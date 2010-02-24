class CcomObject < CcomEntity

  has_one :object_type, :xml_element => "ofObjectType"

  def build_xml(builder)
    super(builder)
    builder.ofObjectType { |b| self.object_type.build_xml(b) } if object_type
  end
end
