class CcomEntity
  include Mongoid::Document

  field :guid
  field :id_in_source
  field :source_id
  field :user_tag
  field :user_name
  field :utc_last_updated, :type => Time
  field :status_code, :type => Integer
  
  before_save :generate_guid

  def to_xml(opts = { })
    opts = { :indent => 2 }.merge(opts)
    builder = Builder::XmlMarkup.new(opts)
    builder.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
    xml = builder.tag!("CCOMData", xml_entity_attributes) do |b|
      b.tag!(xml_entity_name) do |bb|
        build_xml(bb)
      end
    end
  end

  def build_xml(builder)
    [:guid, :id_in_source, :source_id, :user_tag, :user_name, :status_code].each do |attr|
      value = self.send(attr)
      builder.tag!(attr.to_s.camelize(:lower), value) unless value.blank?
    end
  end

  def to_param
    guid
  end
  
  def self.find_by_guid(guid)
    first(:conditions => { :guid => guid })
  end

  def ==(object)
    self._id == object._id rescue false
  end

  private

  def generate_guid
    self.guid = UUID.generate if guid.blank?
  end

  def xml_entity_name
    self.class.to_s.gsub(/^Ccom/, 'CCOM')
  end

  def xml_entity_attributes
    { "xmlns" => MIMOSA_XMLNS,
      "xmlns:xsi" => XSI_XMLNS}
  end
end
