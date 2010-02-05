class CcomEntity
  include Mongoid::Document

  field :guid
  field :id_in_source
  field :source_id
  field :user_tag
  field :user_name
  field :utc_last_updated, :type => DateTime
  field :status_code, :type => Integer
  
end
