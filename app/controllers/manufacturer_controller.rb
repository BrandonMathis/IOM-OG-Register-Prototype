class ManufacturerController < CcomRestController
  def index
    super(Manufacturer.find(:all))
  end
end
