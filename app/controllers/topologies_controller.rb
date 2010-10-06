class TopologiesController < CcomRestController

  def index
    super(Asset.topologies) if request.format == :xml
    @topologies = Asset.topologies if request.format == :html
  end

  def show
    @topology = Asset.first(:conditions => { :g_u_i_d => params[:id]})
  end
end
