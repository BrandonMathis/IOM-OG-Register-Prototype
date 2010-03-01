class MeasLocation < CcomObjectWithEvents
  has_one :default_eng_unit_type, :class_name => "EngUnitType"
  has_many :object_data, :xml_element => "hasObjectData"

  def build_xml(builder)
    super(builder)
    object_data.each do |d|
      builder.hasObjectData do |b|
        d.build_xml(b)
      end
    end
    builder.hasDefaultEngUnitType { |b| default_eng_unit_type.build_xml(b) }
  end
end
