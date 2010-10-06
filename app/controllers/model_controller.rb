class ModelController < CcomRestController
  def index
    super(Model.find(:all))
  end
end
