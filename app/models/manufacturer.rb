class Manufacturer < CcomEntity
  has_one :type, :xml_element => :type
  
  def dup_entity(options = {})
    entity = super(options)
    entity.type = self.type.dup_entity(options) if type
    entity.save
    return entity
  end
end
