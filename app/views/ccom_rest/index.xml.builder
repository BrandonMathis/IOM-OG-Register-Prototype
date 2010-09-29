xml.CCOMData :xmlns => "http://www.mimosa.org/osa-eai/v3-2/xml/CCOM-ML", "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance" do  
  @entities.each do |entity|
    xml.tag!(entity.class.to_s) do
      entity.field_names.each do |field|
        unless (value = entity.send(field)).blank?
          xml.tag!(field.to_s.camelize, value)
        end
      end
    end
  end
end