class MeasLocation < CcomObjectWithEvents
  has_one :default_eng_unit_type, :class_name => "EngUnitType", :xml_element => "DefaultUnitType"
  has_many :object_data, :xml_element => "Attribute"

  # Gives the CCOM XML name for thie entity
  def self.xml_entity_name; "MeasurementLocation" end
  
  # Will duplicated the MeasLocation and all related entities
  def dup_entity (options = {})
    entity = super(options)
    entity.default_eng_unit_type = self.default_eng_unit_type.dup_entity(options) if default_eng_unit_type
    object_data.each { |o| entity.object_data << o.dup_entity(options) if o}
    entity.save
    return entity
  end
  
  # Will destroy the MeasLocation and all related entities
  def destroy
    object_data.each {|o| ObjectDatum.find_by_guid(o.guid).destroy if o && ObjectDatum.find_by_guid(o.guid)}
    super
  end
  
  # XML builder for MeasLocations (called by to_xml)
  def build_xml(builder)
    super(builder)
    object_data.each do |d|
      builder.Attribute do |b|
        d.build_xml(b)
      end
    end
    builder.DefaultUnitType { |b| default_eng_unit_type.build_xml(b) }
  end
end
