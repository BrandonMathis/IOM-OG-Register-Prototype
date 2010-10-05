class TypeController < CcomRestController
  def index
    @entities = ObjectType.find(:all)
    logger.debug("Name #{self.class.to_s}")
    super(@entities)
  end
end
