class String
  def display_name
    return "Native System ID" if self.eql? "IDInInfoSource"
    return "Last Edited" if self.eql? "LastEdited"
    return self
  end
end

class Array
  #def to_xml(opts = {})
  #  opts = { :indent => 2 }.merge(opts)
  #  builder = Builder::XmlMarkup.new(opts)
  #  builder.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
  #  self.each do |entity|
  #    
  #  end
  #end
  
  xml = builder.tag!("CCOMData", self.class.xml_entity_attributes) do |b|
    b.tag!("Entity", "xsi:type" => self.class.xml_entity_name) do |bb|
      build_xml(bb)
    end
  end
  
end