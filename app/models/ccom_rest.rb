class CcomRest
  def error_xml
    opts = { :indent => 2 }.merge(opts)
    builder = Builder::XmlMarkup.new(opts)
    builder.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
    builder
  end
end