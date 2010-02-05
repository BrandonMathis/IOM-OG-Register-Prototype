class CcomEntity
  include Mongoid::Document

  field :guid
  field :id_in_source
  field :source_id
  field :user_tag
  field :user_name
  field :utc_last_updated, :type => DateTime
  field :status_code, :type => Integer
  
  def build_xml(builder)
    [:guid, :id_in_source, :source_id, :user_tag, :user_name, :status_code].each do |attr|
      value = self.send(attr)
      builder.tag!(attr.to_s.camelize(:lower), value) unless value.blank?
    end
  end
end
