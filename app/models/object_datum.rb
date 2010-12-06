class ObjectDatum < CcomObject
  #has_one :attribute_type, :xml_element => "Type"
  has_one :eng_unit_type, :xml_element => "UnitType"
  field :data, :xml_element => "Value"

  # Will give the CCOM XML name of ObjectDatum
  def self.xml_entity_name; "Attribute" end
  
  # Gives the tag of the ObjectDatum's Type
  def attribute_user_tag; object_type.tag rescue ""; end
  
  # Gives the tag of the ObjectDatum's EngUnitType
  def eng_unit_user_tag; eng_unit_type.tag rescue ""; end
  
  # Gives the value of this ObjecDatum in human reable form
  def value
    if eng_unit_type
      "#{data} #{eng_unit_type.tag}"
    else
      data.to_s
    end
  end
  
  # Will duplicated the ObjectDatum and all related entities
  def dup_entity (options={})
    entity = super(options)
    entity.update_attributes(:data => self.data) if data
    entity.eng_unit_type = self.eng_unit_type.dup_entity(options) if eng_unit_type
    entity.save
    return entity
  end

  # XML builder for ObjectDatum (called by to_xml)
  def build_xml(builder)
    super(builder)
    builder.Value { |b| b.Text self.data }
    builder.UnitType { |b| eng_unit_type.build_xml(b) } unless eng_unit_type.blank?
  end

  # Create's an instace of ObjectDatum along with the Type and EngUnitType
  # using some basic information
  def self.create_from_fields(data, attr_type, eng_type)
    create(:data => data,
           :object_type => ObjectType.create(:tag => attr_type),
           :eng_unit_type => EngUnitType.create(:tag => eng_type))
  end

  # Will parse a given XML node to get the numerical value from <Value/>
  def self.parse_xml(entity_node)
    entity = super(entity_node)
    if data_node = entity_node.mimosa_xpath("./Value/*").first
      entity.data = data_node.content
    end
    entity.save
    entity
  end
end
