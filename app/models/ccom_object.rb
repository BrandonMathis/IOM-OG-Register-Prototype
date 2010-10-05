class CcomObject < CcomEntity
  has_one :object_type, :xml_element => "Type"
  before_save :generate_last_edited

  def dup_entity (options = {})
    entity = super(options) 
    entity.update_attributes(:g_u_i_d => UUID.generate) if options[:gen_new_guids]
    entity.object_type = self.object_type.dup_entity(options) if object_type
    entity.save
    return entity
  end
  
  def build_xml(builder)
    super(builder)
    builder.Type { |b| self.object_type.build_xml(b) } if object_type
  end  
end
