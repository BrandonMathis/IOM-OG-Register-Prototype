class Enterprise < CcomObject
  has_one :controlled_site, :class_name => "Site"
end
