class ObjectDatumController < CcomRestController
  def index
    super(ObjectDatum.find(:all))
  end
  
end
