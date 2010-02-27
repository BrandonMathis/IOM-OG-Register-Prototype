class CcomEntity
  include Mongoid::Document
  include CcomXml
  
  field :guid
  field :id_in_source
  field :source_id
  field :user_tag
  field :user_name
  field :utc_last_updated, :type => Time
  field :status_code, :type => Integer

  def self.attributes
    @field_attributes ||= [:guid, :id_in_source, :source_id, :user_tag, :user_name, :status_code]
  end

  def self.field_names
    @field_names ||= fields.keys.reject { |key| association_foreign_keys.include?(key) }.collect(&:to_sym)
  end

  def self.association_foreign_keys
    associations.map { |k, assoc| assoc[:options].foreign_key}
  end

  def field_names
    self.class.field_names
  end
  
  
  before_save :generate_guid

  def user_tag_with_fallback
    tag = user_tag_without_fallback
    tag.blank? ? user_name : tag
  end
  alias_method_chain :user_tag, :fallback

  def to_param
    guid
  end
  
  def self.find_by_guid(guid)
    first(:conditions => { :guid => guid })
  end

  def ==(object)
    self._id == object._id rescue false
  end

  private

  def generate_guid
    self.guid = UUID.generate if guid.blank?
  end

end
