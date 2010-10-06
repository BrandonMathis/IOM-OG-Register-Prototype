class SiteController < CcomRestController
  def index
    super(Site.find(:all))
  end
end
