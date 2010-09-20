class CcomEntity
  include Mongoid::Document
  include CcomXml
  
  field :g_u_i_d           
  field :i_d_in_info_source
  field :tag
  field :name
  field :last_edited
  field :status, :type => Integer

  # Return true if given GUID is a valid UUID
  def self.valid_guid(guid)
    regex = /^(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$/
    return true if guid.gsub(regex)
  end
  
  def guid
    g_u_i_d
  end
  
  def self.attribute_names
    @field_attributes ||= [:g_u_i_d, :i_d_in_info_source, :tag, :name, :last_edited, :status]
  end

  def self.field_names
    [:g_u_i_d, :i_d_in_info_source, :tag, :name, :last_edited, :status]
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
    attributes = {}
    self.field_names.each do |attr|
      attributes[attr] = self.send(attr) if !self.send(attr).blank?
      attributes[:data] = self.data rescue nil      #Added to set the value of Attribute (object_datum)
    end
    if options[:gen_new_guids]
      attributes[:g_u_i_d] = UUID.generate #unless self.class == Type.class
    end
    entity = self.class.create(attributes)
    associations.each do |k, assoc|
      if assoc[:type].to_s =~ /Many/ && !self.send("#{assoc[:options].name}").nil?
        if !self.send("#{assoc[:options].name}").empty?
          self.send("#{assoc[:options].name}").each do |assoc_object|
            entity.send("#{assoc[:options].name}") << assoc_object.dup_entity(options)
          end
        end
      elsif !self.send("#{assoc[:options].name}").nil?
        entity.send("#{assoc[:options].name}=", self.send("#{assoc[:options].name}").dup_entity(options))
      end
    end
    entity.save
    return entity    
  end
  
  private

  def generate_guid
    self.g_u_i_d = UUID.generate if g_u_i_d.blank?
  end
end
