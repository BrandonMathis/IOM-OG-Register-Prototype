class Model < CcomEntity
  has_one :object_type, :xml_element => "Type"
  
  field :product_family
  field :product_family_member
  field :product_family_member_revision
  field :part_number
  
  def self.additional_fields; [:product_family, :product_family_member, :product_family_member_revision, :part_number] end
  def additional_fields; self.class.additional_fields end
  def self.attribute_names; super + additional_fields end
  def self.field_names; super + additional_fields end
  def editable_attribute_names; super + additional_fields end
  
  
  def field_names
    self.class.field_names
  end
  
  def dup_entity(options = {})
    entity = super(options)
    entity.update_attributes(:product_family => product_family) if product_family
    entity.update_attributes(:product_family_member => product_family_member) if product_family_member
    entity.update_attributes(:product_family_member_revision => product_family_member_revision) if product_family_member_revision
    entity.update_attributes(:part_number => part_number) if part_number
    entity.object_type = self.object_type.dup_entity(options) if object_type
    entity.save
    return entity
  end 
end
