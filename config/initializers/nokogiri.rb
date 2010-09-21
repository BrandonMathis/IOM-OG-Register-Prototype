
class String
  def to_mimosa
    self.gsub(/(\/+)/, '\1mimosa:')
  end
end

class Nokogiri::XML::Node
  def mimosa_xpath(path)
    xpath(path.to_mimosa, { "mimosa" => MIMOSA_XMLNS } )
  end
end

