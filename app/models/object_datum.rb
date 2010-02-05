class ObjectDatum < CcomEntity
  has_one :attribute_type
  has_one :eng_unit_type
  field :data

  def build_xml(builder)
    super(builder)
    builder.hasData { |b| b.TextType self.data }
    builder.hasAttributeType { |b| attribute_type.build_xml(b) }
    builder.hasEngUnitType { |b| eng_unit_type.build_xml(b) } unless eng_unit_type.blank?
  end
end
