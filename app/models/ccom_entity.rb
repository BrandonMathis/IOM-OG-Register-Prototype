class CcomEntity
  include Mongoid::Document
  include CcomXml
  
  field :g_u_i_d           
  field :i_d_in_info_source
  field :tag
  field :name
  field :last_edited
  field :status, :object_type => Integer  
  field :created
  
  validates_format_of :g_u_i_d,
                      :with => /(^(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$|^$)/,
                      :message => "is invalid"
                      
  before_create :generate_last_edited, :generate_guid, :generate_created
  before_save :generate_guid, :generate_last_edited, :set_name_and_tag
  
  def guid
    g_u_i_d
  end
  
  def self.get_time
    Time.now.strftime("%Y-%m-%dT%H:%M:%S.#{Time.now.usec}")
  end
  
  def self.attribute_names
    @field_attributes ||= [:g_u_i_d, :i_d_in_info_source, :tag, :name, :last_edited, :created, :status]
  end

  def self.field_names
    [:g_u_i_d, :i_d_in_info_source, :tag, :name, :last_edited, :created, :status]
  end
  
  def editable_attribute_names
    [:g_u_i_d, :i_d_in_info_source, :tag, :name, :status]
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
  
  before_save :generate_guid

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
  
  # Preforms a deep copy of self using relationship and names
  # of those relationships to transend down into the object 
  # tree and recursivly collect values by calling dup_entity
  # related object (children)
  def dup_entity (options = {})
    return self if self.nil?
    attributes = define_attributes
    entity = self.class.create(attributes)
    entity.save
    return entity
  end
  
  def define_attributes
    attributes = {}
    self.field_names.each do |attr|
      attributes[attr] = self.send(attr) if !self.send(attr).blank?
    end
    return attributes
  end
  
  def generate_last_edited
    self.last_edited = CcomEntity.get_time
  end
  
  private

  def generate_guid
    self.g_u_i_d = UUID.generate if g_u_i_d.blank?
  end
  
  def generate_created
    self.created = CcomEntity.get_time
  end
  
  def set_name_and_tag
    self.name = self.class.to_s + ": " + self.guid.to_s if name.blank?
  end
end
