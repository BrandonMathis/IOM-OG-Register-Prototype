class CcomObject < CcomEntity

  has_one :type, :xml_element => "Type"

  def build_xml(builder)
    super(builder)
    builder.Type { |b| self.type.build_xml(b) } if type
  end
end
