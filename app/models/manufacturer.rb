class Manufacturer < CcomEntity
  has_one :object_type, :xml_element => "Type"
  
  # Will duplicated the Manufacturer and all related entities
  def dup_entity(options = {})
    entity = super(options)
    entity.object_type = self.object_type.dup_entity(options) if object_type
    entity.save
    return entity
  end
end
