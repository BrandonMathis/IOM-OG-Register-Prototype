xml.CCOMData :xmlns => "http://www.mimosa.org/osa-eai/v3-2/xml/CCOM-ML", "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance" do  
  @asset.each do |asset|
    xml.Entity "xsi:type" => asset.tag do
      asset.attribute_names.each do |field|
        unless (value = asset.send(field)).blank?
          xml.tag!(field.to_s.camelize, value)
        end
      end
    end
  end
end