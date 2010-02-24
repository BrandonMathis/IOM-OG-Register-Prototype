class CcomObject < CcomEntity

  has_one :object_type, :xml_element => "ofObjectType"

  def self.parse_xml(entity_node)
    entity = super(entity_node)
    associations.each do |k, assoc|
      xpath = "./#{assoc[:options].xml_element}"
      if assoc_entity = entity_node.mimosa_xpath(xpath).first
        entity.send("#{assoc[:options].name}=", assoc[:options].klass.parse_xml(assoc_entity))
      end
    end
#    if object_type_entity = entity_node.mimosa_xpath("./ofObjectType").first
#      entity.object_type = ObjectType.parse_xml(object_type_entity)
#      entity.save
#    end
    entity
  end

  def build_xml(builder)
    super(builder)
    builder.ofObjectType { |b| self.object_type.build_xml(b) } if object_type
  end
end
