# KeysetTS 
# 7 Aug 2010 [10:30 EST]
# Brandon Mathis
#
# Create for CRUD entity form validation

# This Validation currently does not work. I dont know why. Check the Mongoid docs
class Ccom
  include Mongoid::Document
  validates_presence_of :tag
  validate :test
  validates_format_of :g_u_i_d, 
                      :with => /^(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$/    
  def test
    RAILS_DEFAULT_LOGGER.debug("***TEST")
    true
  end
end