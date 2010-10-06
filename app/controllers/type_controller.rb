class TypeController < CcomRestController
  def index 
    super(ObjectType.find(:all))
  end
end
