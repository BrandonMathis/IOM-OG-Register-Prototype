class Segment < MonitoredObject
  has_many :meas_locations
  has_many :installed_assets, :class_name => "Asset"

  def build_xml(builder)
    super(builder)
    meas_locations.each do |m|
      builder.hasMeasLocation do |b|
        m.build_xml(b)
      end
    end
  end
end
