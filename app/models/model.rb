class Model < CcomEntity
  has_one :object_type, :xml_element => "Type"
  
  field :product_family
  field :product_family_member
  field :product_family_member_revision
  field :part_number
  
  # Defines that product_family, product_family_member, product_family_member_revision, and part_number
  # fields must exsit for a Mode  
  def self.additional_fields; [:product_family, :product_family_member, :product_family_member_revision, :part_number] end
  
  # Gives all aditional fields for and instance of Model
  def additional_fields; self.class.additional_fields end
  
  # Give all default and additional attributes for Model
  def self.attribute_names; super + additional_fields end
  
  # Give all default and additional fields for the Model table in the database
  def self.field_names; super + additional_fields end

  # Give list of editable attributes
  def editable_attribute_names; super + additional_fields end

  # Will duplicated the Model and all related entities
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
