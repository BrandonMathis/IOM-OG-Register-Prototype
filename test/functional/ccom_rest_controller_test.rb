require 'test_helper'

class CcomRestControllerTest < ActionController::TestCase
  #--
  # Get Entity Test
  #--
  context "Getting XML" do
    context "of all Entities with empty database" do
      setup do
        get :index, :format => 'xml'
        @doc = Nokogiri::XML.parse(@response.body)
      end
      should "give blank" do
        assert_equal @doc.mimosa_xpath("/CCOMData/*").count, 0
      end
    end
    context "of all Entities with a database containing 3 entities" do
      setup do
        @asset = Factory.create(:manufacturer)
        @segment = Factory.create(:segment)
        @model = Factory.create(:model)
        get :index, :format => 'xml'
        @doc = Nokogiri::XML.parse(@response.body)
      end
      should "get three seperate entities" do
        assert_equal 3, @doc.mimosa_xpath("/CCOMData/*").count
      end
      should "get an asset, segment and model" do
        assert_has_xpath("/CCOMData/Entity[@*='Manufacturer']", @doc)
        assert_has_xpath("/CCOMData/Entity[@*='Segment']", @doc)
        assert_has_xpath("/CCOMData/Entity[@*='Model']", @doc)
      end
    end
    context "of a single Entity" do
      context "with a good GUID" do
        setup do
          @model = Factory.create(:model)
          get :show, :id => @model.guid, :format => 'xml'
          @doc = Nokogiri::XML.parse(@response.body)
        end
        should "return the single entity" do
          assert_equal @model.guid, @doc.mimosa_xpath("/CCOMData/Entity[@*='Model']/GUID").first.content
          assert_equal @model.tag, @doc.mimosa_xpath("/CCOMData/Entity[@*='Model']/Tag").first.content
          assert_equal @model.name, @doc.mimosa_xpath("/CCOMData/Entity[@*='Model']/Name").first.content
          assert_equal @model.created, @doc.mimosa_xpath("/CCOMData/Entity[@*='Model']/Created").first.content
        end
      end
      context "with a bad GUID" do
        setup do
          @guid = UUID.generate
          get :show, :id => @guid, :format => 'xml'
          @doc = Nokogiri::XML.parse(@response.body)
        end
        should "raise an XML error" do
          assert @doc.xpath("/APIError/URL").first.content
          assert_equal @doc.xpath("/APIError/ErrorMessage").first.content, "Could not find requested CCOM Entity with given GUID"
          assert_equal @doc.xpath("/APIError/HTTPMethod").first.content, "GET"
          assert_equal @doc.xpath("/APIError/ErrorCode").first.content, "Mimosa3" 
        end
      end
    end
  end
  #--
  # Create Entity Test
  #--
  context "creating an Entity via RESTful call with XML" do
    setup do
      @guid1 = 'C18340CE-23D3-4B69-A7D4-6BC5378BA0D2'
    end
    context "using good XML" do
      setup do
        @request.env['RAW_POST_DATA'] = '
        <?xml version="1.0" encoding="UTF-8"?>
    		<CCOMData xmlns="http://www.mimosa.org/osa-eai/v3-2/xml/CCOM-ML" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    		<Entity xsi:type="Segment">
    		        <GUID>'+@guid1+'</GUID>
    		        <IDInInfoSource>0000083500000001.25</IDInInfoSource>
    		        <Tag>A Sample Segment</Tag>
    		        <Name>Sample Segment</Name>
    		        <Status>1</Status>
    		        <Type>
    		          <GUID>db1529db-207e-43ed-b146-22124df50e3e</GUID>
    		          <IDInInfoSource>0000000000000000.0.8</IDInInfoSource>
                  <Tag>Aircraft Equipment Production</Tag>
                  <Name>Aircraft Equipment Production</Name>
                  <Status>1</Status>
    		        </Type>
    		</Entity>
    		</CCOMData>'
  		end
  		should 'add a segment to the database' do
        assert_difference("Segment.count", +1) do
          post :create, :format => 'xml'
        end
      end
      should 'give a 201 as response' do
        post :create, :format => 'xml'
        assert_response 201
      end
      should 'create segment and give that segment the specified guid' do
        post :create, :format => 'xml'
        assert Segment.find_by_guid(@guid1)
      end
      should 'return the XML of the generated entity with set last updated time' do
        post :create, :format => 'xml'
        @doc = Nokogiri::XML.parse(@response.body)
        assert_has_xpath("/CCOMData/Entity[@*='Segment']", @doc)
        assert_has_xpath("/CCOMData/Entity[@*='Segment']/GUID", @doc)
        assert_has_xpath("/CCOMData/Entity[@*='Segment']/Tag", @doc)
        assert_has_xpath("/CCOMData/Entity[@*='Segment']/LastEdited", @doc)
        assert_has_xpath("/CCOMData/Entity[@*='Segment']/Created", @doc)
        assert_has_xpath("/CCOMData/Entity[@*='Segment']/Type", @doc)
        assert_has_xpath("/CCOMData/Entity[@*='Segment']/Type/GUID", @doc)
        assert_has_xpath("/CCOMData/Entity[@*='Segment']/Type/Tag", @doc)
      end
    end
    context "using GUID that already exsists in database" do
      setup do
        @request.env['RAW_POST_DATA'] = '
        <?xml version="1.0" encoding="UTF-8"?>
    		<CCOMData xmlns="http://www.mimosa.org/osa-eai/v3-2/xml/CCOM-ML" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    		<Entity xsi:type="Segment">
    		        <GUID>'+@guid1+'</GUID>
    		        <IDInInfoSource>0000083500000001.25</IDInInfoSource>
    		        <Tag>A Sample Segment</Tag>
    		        <Name>Sample Segment</Name>
    		        <Status>1</Status>
    		</Entity>
    		</CCOMData>'
  		  post :create, :format => 'xml'
  		  post :create, :format => 'xml'
  		  @doc = Nokogiri::XML.parse(@response.body)
  		end
  		should "give error Mimosa5 XML" do
		    assert @doc.xpath("/APIError/URL").first.content
        assert_equal "GUID in give XML already exsists in database. GUID: "+@guid1,  @doc.xpath("/APIError/ErrorMessage").first.content
        assert_equal "POST", @doc.xpath("/APIError/HTTPMethod").first.content
		  end
    end
    context "using blank GUID" do
      setup do
        @request.env['RAW_POST_DATA'] = '
        <?xml version="1.0" encoding="UTF-8"?>
    		<CCOMData xmlns="http://www.mimosa.org/osa-eai/v3-2/xml/CCOM-ML" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    		<Entity xsi:type="Segment">
    		        <GUID></GUID>
    		        <IDInInfoSource>0000083500000001.25</IDInInfoSource>
    		        <Tag>A Sample Segment</Tag>
    		        <Name>Sample Segment</Name>
    		        <Status>1</Status>
    		        <Type>
    		          <GUID>db1529db-207e-43ed-b146-22124df50e3e</GUID>
    		          <IDInInfoSource>0000000000000000.0.8</IDInInfoSource>
                  <Tag>Aircraft Equipment Production</Tag>
                  <Name>Aircraft Equipment Production</Name>
                  <Status>1</Status>
    		        </Type>
    		</Entity>
    		</CCOMData>'
      end
      should "add a segment to the database" do
        assert_difference("Segment.count", +1) do
          post :create, :format => 'xml'
        end
      end
      should "assign a GUID to the empty GUID attr" do
        post :create, :format => 'xml'
        @doc = Nokogiri::XML.parse(@response.body)
        guid = @doc.mimosa_xpath("/CCOMData/Entity[@*='Segment']/GUID").first.content
        assert guid =~ /(^(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$|^$)/
      end          
    end
    context "using invalid GUID" do
      setup do
        @request.env['RAW_POST_DATA'] = '
        <?xml version="1.0" encoding="UTF-8"?>
    		<CCOMData xmlns="http://www.mimosa.org/osa-eai/v3-2/xml/CCOM-ML" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    		<Entity xsi:type="Segment">
    		        <GUID>badguid1</GUID>
    		        <IDInInfoSource>0000083500000001.25</IDInInfoSource>
    		        <Tag>A Sample Segment</Tag>
    		        <Name>Sample Segment</Name>
    		        <Status>1</Status>
    		        <Type>
    		          <GUID>db1529db-207e-43ed-b146-22124df50e3e</GUID>
    		          <IDInInfoSource>0000000000000000.0.8</IDInInfoSource>
                  <Tag>Aircraft Equipment Production</Tag>
                  <Name>Aircraft Equipment Production</Name>
                  <Status>1</Status>
    		        </Type>
    		</Entity>
    		</CCOMData>'
      end
      should "generate an exception" do
        post :create, :format => 'xml'
        @doc = Nokogiri::XML.parse(@response.body)
        assert @doc.xpath("/APIError/URL").first.content
        assert_equal "Given XML contains an invalid value for GUID", @doc.xpath("/APIError/ErrorMessage").first.content
        assert_equal "POST", @doc.xpath("/APIError/HTTPMethod").first.content
      end
    end
    context "using XML with no type" do
      setup do
        @request.env['RAW_POST_DATA'] = '
        <?xml version="1.0" encoding="UTF-8"?>
    		<CCOMData xmlns="http://www.mimosa.org/osa-eai/v3-2/xml/CCOM-ML" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    		<Entity xsi:type="Type">
    		        <GUID>'+@guid1+'</GUID>
    		        <IDInInfoSource>0000083500000001.25</IDInInfoSource>
    		        <Tag>Some Type</Tag>
    		        <Name>Some Type</Name>
    		        <Status>1</Status>
    		</Entity>
    		</CCOMData>'
  		end
  		should "NOT generate types for Entity" do
		    post :create, :format => 'xml'
		    @doc = Nokogiri::XML.parse(@response.body)
		    assert @doc.mimosa_xpath("/CCOMData/Entity[@*='Type']/Type").blank?
		  end
		end
  end
  #--
  # Edit Entity Test
  #--
  context "edited an Asset via RESTful call with XMl" do
    setup do
      @model = Factory.create(:model)
      get :show, :id => @model.guid, :format => 'xml' #Initial query for ETag
      @etag = @response.etag
      @doc = Nokogiri::XML.parse(@response.body)
      @request.env['RAW_POST_DATA'] = @model.to_xml
    end
    
    should "have etag" do
      assert @response.etag
    end
    
    should "return model XML with query for ETag" do
      assert_has_xpath("/CCOMData/Entity[@*='Model']", @doc)
      assert_has_xpath("/CCOMData/Entity[@*='Model']/GUID", @doc)
    end
    context "with old eTag" do
      setup do
        @model.update_attributes(:name => "changed")
        @request.env["HTTP_IF_NONE_MATCH"] = @etag
      end
      should "not edit entity if etag has expired" do
        put :update, :id => @model.guid, :format => 'xml'
        assert_response 412
      end
    end
    context "with fresh eTag" do
      setup do
        @request.env["HTTP_IF_NONE_MATCH"] = @etag
      end
      should "update the entity if etag is same as server" do
        put :update, :id => @model.guid, :format => 'xml'
        assert_response 201
      end
    end
  end
  #--
  # Delete Entity Test
  #--
  context "Deleting a CCOMEntity via RESTful call" do
    setup do
      @entity = Factory.create(:ccom_entity)
    end
    
    should 'delete the entity' do
      assert_difference('CcomEntity.count', -1) do
        delete :destroy, :id => @entity.g_u_i_d, :format => 'xml'
      end
    end
    
    should "return xml of destroyed entity" do
      delete :destroy, :id => @entity.guid, :format => 'xml'
      @doc = Nokogiri::XML.parse(@response.body)
      guid = @doc.mimosa_xpath("/CCOMData/Entity/GUID").first.content
      assert guid =~ /(^(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$|^$)/
    end
    
    context "With a GUID that doesnt exsist in db" do
      setup do
        delete :destroy, :id => @entity.g_u_i_d, :format => 'xml'
      end
      
      should 'give an error when GUID doesnt exsist' do
        delete :destroy, :id => @entity.g_u_i_d, :format => 'xml'
        @doc = Nokogiri::XML.parse(@response.body)
        assert @doc.xpath("/APIError/URL").first.content
        assert_equal @doc.xpath("/APIError/ErrorMessage").first.content, "Could not find requested CCOM Entity with given GUID"
        assert_equal @doc.xpath("/APIError/HTTPMethod").first.content, "DELETE"
      end
    end
  end
end
