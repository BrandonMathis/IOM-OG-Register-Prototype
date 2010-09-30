class CcomRest
  def self.error_xml(message = {})
    opts = { :indent => 2 }
    builder = Builder::XmlMarkup.new(opts)
    builder.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
    builder.CCOMError do
      builder.method message[:method]
      builder.errorMessage message[:errorMessage]
      builder.arguments do
        builder.CCOMEntity message[:entity]
      end
    end
  end  
end