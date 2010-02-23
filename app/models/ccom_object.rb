class CcomObject < CcomEntity

  has_one :object_type

  def self.parse_xml(entity_node)
    entity = super(entity_node)
    if object_type_entity = entity_node.mimosa_xpath("./ofObjectType").first
      entity.object_type = ObjectType.parse_xml(object_type_entity)
      entity.save
    end
    entity
  end

  def build_xml(builder)
    super(builder)
    builder.ofObjectType { |b| self.object_type.build_xml(b) } if object_type
  end
end
