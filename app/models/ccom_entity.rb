class CcomEntity
  include Mongoid::Document
  include CcomXml
  
  field :g_u_i_d           
  field :i_d_in_info_source
  field :source_id
  field :tag
  field :name
  field :last_edited
  field :status, :type => Integer

  def self.attribute_names
    @field_attributes ||= [:g_u_i_d, :i_d_in_info_source, :source_id, :tag, :name, :last_edited, :status]
  end

  def self.field_names
    # @field_names ||= fields.keys.reject { |key| association_foreign_keys.include?(key) }.collect(&:to_sym)
    [:g_u_i_d, :i_d_in_info_source, :source_id, :tag, :name, :last_edited, :status]
  end

  def self.association_foreign_keys
    associations.map { |k, assoc| assoc[:options].foreign_key}
  end

  def field_names
    self.class.field_names
  end
  
  def attribute_names
    self.class.attribute_names
  end
  
  before_save :generate_guid, :generate_last_edited

  def tag_with_fallback
    tag = tag_without_fallback
    tag.blank? ? name : tag
  end
  alias_method_chain :tag, :fallback

  def to_param
    g_u_i_d
  end
  
  def self.find_by_guid(globally_unique_identifier)
    first(:conditions => { :g_u_i_d => globally_unique_identifier })
  end

  def ==(object)
    self._id == object._id rescue false
  end

  private

  def generate_guid
    self.g_u_i_d = UUID.generate if g_u_i_d.blank?
  end
  
  def generate_last_edited
    self.last_edited = Time.now.strftime('%Y-%m-%dT%H:%M:%S')
  end

end
