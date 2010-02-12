require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RequestStub do

  before(:each) do
    @request_stub = RequestStub.new(:get, "www.example.com")
  end

  it "should have request profile with method and uri" do
    @request_stub.request_profile.method.should == :get
    @request_stub.request_profile.uri.host.should == "www.example.com"
  end

  it "should have response" do
    @request_stub.response.should be_a(WebMock::Response)
  end

  describe "with" do

    it "should assign body to request profile" do
      @request_stub.with(:body => "abc")
      @request_stub.request_profile.body.should == RequestProfile::Body.new("abc")
    end

    it "should assign normalized headers to request profile" do
      Util::Headers.should_receive(:normalize_headers).with('A' => 'a').and_return('B' => 'b')
      @request_stub.with(:headers => {'A' => 'a'})
      @request_stub.request_profile.headers.should == {'B' => 'b'}
    end

    it "should assign given block to request profile" do
      @request_stub.with { |req| "block output" }
      @request_stub.request_profile.with_block.call(nil).should == "block output"
    end

  end

  describe "to_return" do

    it "should assign response with provided options" do
      @request_stub.to_return(:body => "abc", :status => 500)
      @request_stub.response.body.should == "abc"
      @request_stub.response.status.should == 500
    end

    it "should assign responses with provided options" do
      @request_stub.to_return([{:body => "abc"}, {:body => "def"}])
      [@request_stub.response.body, @request_stub.response.body].should == ["abc", "def"]
    end

  end

  describe "then" do
    it "should return stub without any modifications, acting as syntactic sugar" do
      @request_stub.then.should == @request_stub
    end
  end

  describe "response" do

    it "should return responses in a sequence passed as array" do
      @request_stub.to_return([{:body => "abc"}, {:body => "def"}])
      @request_stub.response.body.should == "abc"
      @request_stub.response.body.should == "def"
    end

    it "should repeat returning last response" do
      @request_stub.to_return([{:body => "abc"}, {:body => "def"}])
      @request_stub.response
      @request_stub.response
      @request_stub.response.body.should == "def"
    end
    
    it "should return responses in a sequence passed as comma separated params" do
      @request_stub.to_return({:body => "abc"}, {:body => "def"})
      @request_stub.response.body.should == "abc"
      @request_stub.response.body.should == "def"
    end
    
    it "should return responses declared in multiple to_return declarations" do
      @request_stub.to_return({:body => "abc"}).to_return({:body => "def"})
      @request_stub.response.body.should == "abc"
      @request_stub.response.body.should == "def"
    end

  end

  describe "to_raise" do

    it "should assign response with exception to be thrown" do
      @request_stub.to_raise(ArgumentError)
      lambda {
        @request_stub.response.raise_error_if_any
      }.should raise_error(ArgumentError, "Exception from WebMock")
    end
    
    it "should assign sequence of responses with response with exception to be thrown" do
      @request_stub.to_return(:body => "abc").then.to_raise(ArgumentError)
      @request_stub.response.body.should == "abc"
      lambda {
        @request_stub.response.raise_error_if_any
      }.should raise_error(ArgumentError, "Exception from WebMock")
    end

    it "should assign a list responses to be thrown in a sequence" do
      @request_stub.to_raise(ArgumentError, IndexError)
      lambda {
        @request_stub.response.raise_error_if_any
      }.should raise_error(ArgumentError, "Exception from WebMock")
      lambda {
        @request_stub.response.raise_error_if_any
      }.should raise_error(IndexError, "Exception from WebMock")
    end
    
    it "should raise exceptions declared in multiple to_raise declarations" do
       @request_stub.to_raise(ArgumentError).then.to_raise(IndexError)
        lambda {
          @request_stub.response.raise_error_if_any
        }.should raise_error(ArgumentError, "Exception from WebMock")
        lambda {
          @request_stub.response.raise_error_if_any
        }.should raise_error(IndexError, "Exception from WebMock")
    end

  end
  
  
  describe "times" do
    
    it "should give error if declared before any response declaration is declared" do
      lambda {
        @request_stub.times(3)
       }.should raise_error("Invalid WebMock stub declaration. times(N) can be declared only after response declaration.")  
    end
    
    it "should repeat returning last declared response declared number of times" do
      @request_stub.to_return({:body => "abc"}).times(2).then.to_return({:body => "def"})
      @request_stub.response.body.should == "abc"
      @request_stub.response.body.should == "abc"
      @request_stub.response.body.should == "def"
    end
    
    it "should repeat raising last declared exception declared number of times" do
      @request_stub.to_return({:body => "abc"}).times(2).then.to_return({:body => "def"})
      @request_stub.response.body.should == "abc"
      @request_stub.response.body.should == "abc"
      @request_stub.response.body.should == "def"
    end
    
    it "should repeat returning last declared sequence of responses declared number of times" do
      @request_stub.to_return({:body => "abc"}, {:body => "def"}).times(2).then.to_return({:body => "ghj"})
      @request_stub.response.body.should == "abc"
      @request_stub.response.body.should == "def"
      @request_stub.response.body.should == "abc"
      @request_stub.response.body.should == "def"
      @request_stub.response.body.should == "ghj"
    end
    
    it "should return self" do
      @request_stub.to_return({:body => "abc"}).times(1).should == @request_stub
    end
    
    it "should raise error if argument is not integer" do
      lambda {
         @request_stub.to_return({:body => "abc"}).times("not number")
      }.should raise_error("times(N) accepts integers >= 1 only")  
    end
    
    it "should raise error if argument is < 1" do
      lambda {
        @request_stub.to_return({:body => "abc"}).times(0)
      }.should raise_error("times(N) accepts integers >= 1 only")  
    end
    
  end

end
