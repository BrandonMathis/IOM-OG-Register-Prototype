require 'test_helper'

class CcomControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "proper template html" do
    get :index, :format => 'html'
    assert_template "ccom/index.html.erb"
    
    get :show, :format => 'html'
    assert_template "ccom/show.html.erb"
  end
  
  test "proper template xml" do    
    get(:index, :format => 'xml')
    assert_template "index.xml.builder"
    
    get(:show, :format => 'xml')
    assert_template "show.xml.builder"
  end    
end