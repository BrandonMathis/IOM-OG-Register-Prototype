class ObjectDatum < CcomEntity
  has_one :attribute_type
  has_one :eng_unit_type
  field :data

  def attribute_user_tag; attribute_type.user_tag rescue ""; end
  def eng_unit_user_tag; eng_unit_type.user_tag rescue ""; end
  def value
    if eng_unit_type
      "#{data} #{eng_unit_type.user_tag}"
    else
      data.to_s
    end
  end

  def build_xml(builder)
    super(builder)
    builder.hasData { |b| b.TextType self.data }
    builder.hasAttributeType { |b| attribute_type.build_xml(b) }
    builder.hasEngUnitType { |b| eng_unit_type.build_xml(b) } unless eng_unit_type.blank?
  end

  def self.create_from_fields(data, attr_type, eng_type)
    create(:data => data,
           :attribute_type => AttributeType.create(:user_tag => attr_type),
           :eng_unit_type => EngUnitType.create(:user_tag => eng_type))
  end

end
