module CcomXml

  def self.included(base)
    base.class_eval do
      include InstanceMethods
      extend ClassMethods
    end
  end

  module ClassMethods
    def valid_guid(guid)
      regex = /^(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$/
      return true if guid.gsub(regex)
    end
    
    def from_xml(xml)
      doc = Nokogiri::XML.parse(xml)
      entity_node = doc.mimosa_xpath("/CCOMData/Entity[@*='#{xml_entity_name}']").first
      parse_xml(entity_node)
    end

    def parse_xml(entity_node)
      attributes = { }
      self.field_names.each do |attr|
        if node = entity_node.mimosa_xpath("./#{attr_to_camel(attr)}").first
          attributes[attr] =  node.content
        end
      end
      if entity = find_by_guid(attributes[:g_u_i_d])
        entity.update_attributes(attributes)
      else
        entity = create(attributes)
      end
      parse_associations(entity, entity_node)
      entity.save
      entity
    end

    def parse_associations(entity, entity_node)
      associations.each do |k, assoc|
        xpath = "./#{assoc[:options].xml_element}"
        entity_node.mimosa_xpath(xpath).each do |assoc_entity|
          assoc_object = assoc[:options].klass.parse_xml(assoc_entity)
          if assoc[:type].to_s =~ /Many/
            entity.send("#{assoc[:options].name}") << assoc_object
          else
            entity.send("#{assoc[:options].name}=", assoc_object)
          end
        end
      end
    end

    def xml_entity_name
      self.to_s.gsub(/^Ccom/, 'CCOM')
    end

    def xml_entity_attributes
      { "xmlns" => MIMOSA_XMLNS,
        "xmlns:xsi" => XSI_XMLNS}
    end

    def attr_to_camel(attr)
      attr.to_s.camelize()
    end
    
  end

  module InstanceMethods
    def to_xml(opts = { })
      opts = { :indent => 2 }.merge(opts)
      builder = Builder::XmlMarkup.new(opts)
      builder.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
      xml = builder.tag!("CCOMData", self.class.xml_entity_attributes) do |b|
        b.tag!("Entity", "xsi:type" => self.class.xml_entity_name) do |bb|
          build_xml(bb)
        end
      end
    end

    def build_xml(builder)
      self.field_names.each do |attr|
        value = self.send(attr)
        builder.tag!(self.class.attr_to_camel(attr), value) unless value.blank?
      end
    end
  end

end
