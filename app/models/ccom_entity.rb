class CcomEntity
  include Mongoid::Document

  
  field :guid
  field :id_in_source
  field :source_id
  field :user_tag
  field :user_name
  field :utc_last_updated, :type => Time
  field :status_code, :type => Integer

  ATTRIBUTES = [:guid, :id_in_source, :source_id, :user_tag, :user_name, :status_code]
  
  before_save :generate_guid

  def user_tag_with_fallback
    tag = user_tag_without_fallback
    tag.blank? ? user_name : tag
  end
  alias_method_chain :user_tag, :fallback


  def self.from_xml(xml)
    doc = Nokogiri::XML.parse(xml)
    entity_node = doc.mimosa_xpath("/CCOMData/#{xml_entity_name}").first
    parse_xml(entity_node)
  end

  def self.parse_xml(entity_node)
    attributes = { }
    ATTRIBUTES.each do |attr|
      if node = entity_node.mimosa_xpath("./#{attr_to_camel(attr)}").first
        attributes[attr] =  node.content
      end
    end
    if entity = find_by_guid(attributes[:guid])
      entity.update_attributes(attributes)
    else
      entity = create(attributes)
    end
    entity
  end

  def to_xml(opts = { })
    opts = { :indent => 2 }.merge(opts)
    builder = Builder::XmlMarkup.new(opts)
    builder.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
    xml = builder.tag!("CCOMData", xml_entity_attributes) do |b|
      b.tag!(self.class.xml_entity_name) do |bb|
        build_xml(bb)
      end
    end
  end

  def build_xml(builder)
    ATTRIBUTES.each do |attr|
      value = self.send(attr)
      builder.tag!(self.class.attr_to_camel(attr), value) unless value.blank?
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

  def self.attr_to_camel(attr)
    attr.to_s.camelize(:lower)
  end

  def generate_guid
    self.guid = UUID.generate if guid.blank?
  end

  def self.xml_entity_name
    self.to_s.gsub(/^Ccom/, 'CCOM')
  end

  def xml_entity_attributes
    { "xmlns" => MIMOSA_XMLNS,
      "xmlns:xsi" => XSI_XMLNS}
  end
end
