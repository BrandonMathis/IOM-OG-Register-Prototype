class CcomObject < CcomEntity
  has_one :type, :xml_element => "Type"
  before_save :generate_last_edited

  def dup_entity (options = {})
    entity = super(options) 
    entity.update_attributes(:g_u_i_d => UUID.generate) if options[:gen_new_guids]
    entity.type = self.type.dup_entity(options) if type
    entity.save
    return entity
  end
  
  def build_xml(builder)
    super(builder)
    builder.Type { |b| self.type.build_xml(b) } if type
  end  
end
