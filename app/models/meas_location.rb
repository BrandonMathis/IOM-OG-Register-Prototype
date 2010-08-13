class MeasLocation < CcomObjectWithEvents
  has_one :default_eng_unit_type, :class_name => "EngUnitType", :xml_element => "DefaultUnitType"
  has_many :object_data, :xml_element => "Attribute"

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
