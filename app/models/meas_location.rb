class MeasLocation < CcomObjectWithEvents
  has_one :default_eng_unit_type, :name => :eng_unit_type
  has_one :object_type
  has_many :object_data

  def build_xml(builder)
    super(builder)
    builder.ofObjectType { |b| self.object_type.build_xml(b) }
    object_data.each do |d|
      builder.hasObjectData do |b|
        d.build_xml(b)
      end
    end
    builder.hasDefaultEngUnitType { |b| default_eng_unit_type.build_xml(b) }
  end
end
