class CcomEntity
  include Mongoid::Document

  field :guid
  field :id_in_source
  field :source_id
  field :user_tag
  field :user_name
  field :utc_last_updated, :type => DateTime
  field :status_code, :type => Integer
  
  def to_xml
    builder = Builder::XmlMarkup.new
    builder.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
    xml = builder.tag!(xml_entity_name, xml_entity_attributes) do |b|
      build_xml(b)
    end
  end

  def build_xml(builder)
    [:guid, :id_in_source, :source_id, :user_tag, :user_name, :status_code].each do |attr|
      value = self.send(attr)
      builder.tag!(attr.to_s.camelize(:lower), value) unless value.blank?
    end
  end

  def self.xmlns; "http://www.mimosa.org/osa-eai/v3-3/xml/CCOM-ML"; end

  private

  def xml_entity_name; "CCOMEntity"; end

  def xml_entity_attributes
    { "xmlns" => self.class.xmlns }
  end
end
