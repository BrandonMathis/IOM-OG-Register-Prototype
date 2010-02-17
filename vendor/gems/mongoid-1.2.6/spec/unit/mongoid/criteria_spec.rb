require "spec_helper"

describe Mongoid::Criteria do

  before do
    @criteria = Mongoid::Criteria.new(Person)
    @canvas_criteria = Mongoid::Criteria.new(Canvas)
  end

  describe "#+" do

    before do
      @sir = Person.new(:title => "Sir")
      @canvas = Canvas.new
    end

    context "when the criteria has not been executed" do

      before do
        @collection = mock
        @cursor = stub(:count => 1)
        @cursor.expects(:each).at_least_once.yields(@sir)
        Person.expects(:collection).at_least_once.returns(@collection)
        @collection.expects(:find).at_least_once.returns(@cursor)
      end

      it "executes the criteria and concats the results" do
        results = @criteria + [ @canvas ]
        results.should == [ @sir, @canvas ]
      end

    end

    context "when the other is a criteria" do

      before do
        @collection = mock
        @canvas_collection = mock
        @cursor = stub(:count => 1)
        @canvas_cursor = stub(:count => 1)
        @cursor.expects(:each).at_least_once.yields(@sir)
        @canvas_cursor.expects(:each).at_least_once.yields(@canvas)
        Person.expects(:collection).at_least_once.returns(@collection)
        @collection.expects(:find).at_least_once.returns(@cursor)
        Canvas.expects(:collection).at_least_once.returns(@canvas_collection)
        @canvas_collection.expects(:find).at_least_once.returns(@canvas_cursor)
      end

      it "concats the results" do
        results = @criteria + @canvas_criteria
        results.should == [ @sir, @canvas ]
      end

    end

  end

  describe "#-" do

    before do
      @sir = Person.new(:title => "Sir")
      @madam = Person.new(:title => "Madam")
    end

    context "when the criteria has not been executed" do

      before do
        @collection = mock
        @cursor = stub(:count => 1)
        @cursor.expects(:each).yields(@madam)
        Person.expects(:collection).returns(@collection)
        @collection.expects(:find).returns(@cursor)
      end

      it "executes the criteria and returns the difference" do
        results = @criteria - [ @sir ]
        results.should == [ @madam ]
      end

    end

  end

  describe "#[]" do

    before do
      @criteria.where(:title => "Sir")
      @collection = stub
      @person = Person.new(:title => "Sir")
      @cursor = stub(:count => 10)
      @cursor.expects(:each).yields(@person)
    end

    context "when the criteria has not been executed" do

      before do
        Person.expects(:collection).returns(@collection)
        @collection.expects(:find).with({ :title => "Sir", :_type => { "$in" => ["Doctor", "Person"] } }, {}).returns(@cursor)
      end

      it "executes the criteria and returns the element at the index" do
        @criteria[0].should == @person
      end

    end

  end

  describe "#aggregate" do

    before do
      @context = stub.quacks_like(Mongoid::Contexts::Mongo.allocate)
      @criteria.instance_variable_set(:@context, @context)
    end

    it "delegates to the context" do
      @context.expects(:aggregate)
      @criteria.aggregate
    end

  end

  describe "#blank?" do

    before do
      @context = stub.quacks_like(Mongoid::Contexts::Mongo.allocate)
      @criteria.instance_variable_set(:@context, @context)
    end

    context "when the count is 0" do

      before do
        @context.expects(:count).returns(0)
      end

      it "returns true" do
        @criteria.blank?.should be_true
      end
    end

    context "when the count is greater than 0" do

      before do
        @context.expects(:count).returns(10)
      end

      it "returns false" do
        @criteria.blank?.should be_false
      end
    end
  end

  describe "#context" do

    context "when the context has been set" do

      before do
        @context = stub
        @criteria.instance_variable_set(:@context, @context)
      end

      it "returns the memoized context" do
        @criteria.context.should == @context
      end

    end

    context "when the context has not been set" do

      before do
        @context = stub
      end

      it "creates a new context" do
        Mongoid::Contexts::Mongo.expects(:new).with(
          @criteria.selector, @criteria.options, @criteria.klass
        ).returns(@context)
        @criteria.context.should == @context
      end

    end

    context "when the class is embedded" do

      before do
        @criteria = Mongoid::Criteria.new(Address)
      end

      it "returns an enumerable context" do
        @criteria.context.should be_a_kind_of(Mongoid::Contexts::Enumerable)
      end

    end

    context "when the class is not embedded" do

      it "returns a mongo context" do
        @criteria.context.should be_a_kind_of(Mongoid::Contexts::Mongo)
      end

    end

  end

  describe "#entries" do

    context "filtering" do

      before do
        @collection = mock
        Person.expects(:collection).returns(@collection)
        @criteria = Mongoid::Criteria.new(Person).extras(:page => 1, :per_page => 20)
        @collection.expects(:find).with(@criteria.selector, @criteria.options).returns([])
      end

      it "filters out unused params" do
        @criteria.entries
        @criteria.options[:page].should be_nil
        @criteria.options[:per_page].should be_nil
      end

    end

    context "when type is :all" do

      before do
        @collection = mock
        Person.expects(:collection).returns(@collection)
        @criteria = Mongoid::Criteria.new(Person).extras(:page => 1, :per_page => 20)
        @cursor = stub(:count => 44)
        @cursor.expects(:each)
        @collection.expects(:find).with(@criteria.selector, @criteria.options).returns(@cursor)
      end

      it "does not add the count instance variable" do
        @criteria.entries.should == []
        @criteria.instance_variable_get(:@count).should be_nil
      end

    end

    context "when type is not :first" do

      it "calls find on the collection with the selector and options" do
        criteria = Mongoid::Criteria.new(Person)
        collection = mock
        Person.expects(:collection).returns(collection)
        collection.expects(:find).with(@criteria.selector, @criteria.options).returns([])
        criteria.entries.should == []
      end

    end

  end

  describe "#count" do

    before do
      @context = stub.quacks_like(Mongoid::Contexts::Mongo.allocate)
      @criteria.instance_variable_set(:@context, @context)
    end

    it "delegates to the context" do
      @context.expects(:count).returns(10)
      @criteria.count.should == 10
    end

  end

  describe "#each" do

    before do
      @criteria.where(:title => "Sir")
      @collection = stub
      @person = Person.new(:title => "Sir")
      @cursor = stub(:count => 10)
    end

    context "when the criteria has not been executed" do

      before do
        Person.expects(:collection).returns(@collection)
        @collection.expects(:find).with({ :_type => { "$in" => ["Doctor", "Person"] }, :title => "Sir" }, {}).returns(@cursor)
        @cursor.expects(:each).yields(@person)
      end

      it "executes the criteria" do
        @criteria.each do |doc|
          doc.should == @person
        end
      end

    end

    context "when the criteria has been executed" do

      before do
        Person.expects(:collection).returns(@collection)
        @collection.expects(:find).with({ :_type => { "$in" => ["Doctor", "Person"] }, :title => "Sir" }, {}).returns(@cursor)
        @cursor.expects(:each).yields(@person)
      end

      it "calls each on the existing results" do
        @criteria.each do |person|
          person.should == @person
        end
      end

    end

    context "when no block is passed" do

      it "returns self" do
        @criteria.each.should == @criteria
      end

    end

    context "when caching" do

      before do
        Person.expects(:collection).returns(@collection)
        @collection.expects(:find).with({ :_type => { "$in" => ["Doctor", "Person"] }, :title => "Sir" }, {}).returns(@cursor)
        @cursor.expects(:each).yields(@person)
        @criteria.cache
        @criteria.each do |doc|
          doc.should == @person
        end
      end

      it "caches the results of the cursor iteration" do
        @criteria.each do |doc|
          doc.should == @person
        end
        # Do it again for sanity's sake.
        @criteria.each do |doc|
          doc.should == @person
        end
      end

    end

  end

  describe "#first" do

    before do
      @context = stub.quacks_like(Mongoid::Contexts::Mongo.allocate)
      @criteria.instance_variable_set(:@context, @context)
    end

    it "delegates to the context" do
      @context.expects(:first).returns([])
      @criteria.first.should == []
    end

  end

  describe "#group" do

    before do
      @context = stub.quacks_like(Mongoid::Contexts::Mongo.allocate)
      @criteria.instance_variable_set(:@context, @context)
    end

    it "delegates to the context" do
      @context.expects(:group).returns({})
      @criteria.group.should == {}
    end

  end

  describe "#initialize" do

    context "when class is hereditary" do

      it "sets the _type value on the selector" do
        criteria = Mongoid::Criteria.new(Person)
        criteria.selector.should == { :_type => { "$in" => ["Doctor", "Person"] } }
      end

    end

    context "when class is not hereditary" do

      it "sets no _type value on the selector" do
        criteria = Mongoid::Criteria.new(Game)
        criteria.selector.should == {}
      end

    end

  end

  describe "#last" do

    before do
      @context = stub.quacks_like(Mongoid::Contexts::Mongo.allocate)
      @criteria.instance_variable_set(:@context, @context)
    end

    it "delegates to the context" do
      @context.expects(:last).returns([])
      @criteria.last.should == []
    end

  end

  describe "#max" do

    before do
      @context = stub.quacks_like(Mongoid::Contexts::Mongo.allocate)
      @criteria.instance_variable_set(:@context, @context)
    end

    it "delegates to the context" do
      @context.expects(:max).with(:field).returns(100)
      @criteria.max(:field).should == 100
    end

  end

  describe "#merge" do

    before do
      @criteria.where(:title => "Sir", :age => 30).skip(40).limit(20)
    end

    context "with another criteria" do

      context "when the other has a selector and options" do

        before do
          @other = Mongoid::Criteria.new(Person)
          @other.where(:name => "Chloe").order_by([[:name, :asc]])
          @selector = { :_type => { "$in" => ["Doctor", "Person"] }, :title => "Sir", :age => 30, :name => "Chloe" }
          @options = { :skip => 40, :limit => 20, :sort => [[:name, :asc]] }
        end

        it "merges the selector and options hashes together" do
          @criteria.merge(@other)
          @criteria.selector.should == @selector
          @criteria.options.should == @options
        end

      end

      context "when the other has no selector or options" do

        before do
          @other = Mongoid::Criteria.new(Person)
          @selector = { :_type => { "$in" => ["Doctor", "Person"] }, :title => "Sir", :age => 30 }
          @options = { :skip => 40, :limit => 20 }
        end

        it "merges the selector and options hashes together" do
          @criteria.merge(@other)
          @criteria.selector.should == @selector
          @criteria.options.should == @options
        end

      end

      context "when the other has a document collection" do

        before do
          @documents = [ stub ]
          @other = Mongoid::Criteria.new(Person)
          @other.documents = @documents
        end

        it "merges the documents collection in" do
          @criteria.merge(@other)
          @criteria.documents.should == @documents
        end

      end

    end

  end

  describe "#method_missing" do

    before do
      @criteria = Mongoid::Criteria.new(Person)
      @criteria.where(:title => "Sir")
    end

    it "merges the criteria with the next one" do
      @new_criteria = @criteria.accepted
      @new_criteria.selector.should == { :_type => { "$in" => ["Doctor", "Person"] }, :title => "Sir", :terms => true }
    end

    context "chaining more than one scope" do

      before do
        @criteria = Person.accepted.old.knight
      end

      it "returns the final merged criteria" do
        @criteria.selector.should ==
          { :_type => { "$in" => ["Doctor", "Person"] }, :title => "Sir", :terms => true, :age => { "$gt" => 50 } }
      end

    end

    context "when expecting behaviour of an array" do

      before do
        @array = mock
        @document = mock
      end

      describe "#[]" do

        it "collects the criteria and calls []" do
          @criteria.expects(:entries).returns([@document])
          @criteria[0].should == @document
        end

      end

      describe "#rand" do

        it "collects the criteria and call rand" do
          @criteria.expects(:entries).returns(@array)
          @array.expects(:send).with(:rand).returns(@document)
          @criteria.rand
        end

      end

    end

  end

  describe "#min" do

    before do
      @context = stub.quacks_like(Mongoid::Contexts::Mongo.allocate)
      @criteria.instance_variable_set(:@context, @context)
    end

    it "delegates to the context" do
      @context.expects(:min).with(:field).returns(100)
      @criteria.min(:field).should == 100
    end

  end

  describe "#offset" do

  end

  describe "#one" do

    before do
      @context = stub.quacks_like(Mongoid::Contexts::Mongo.allocate)
      @criteria.instance_variable_set(:@context, @context)
    end

    it "delegates to the context" do
      @context.expects(:one)
      @criteria.one
    end

  end

  describe "#page" do

    before do
      @context = stub.quacks_like(Mongoid::Contexts::Mongo.allocate)
      @criteria.instance_variable_set(:@context, @context)
    end

    it "delegates to the context" do
      @context.expects(:page).returns(1)
      @criteria.page.should == 1
    end

  end

  describe "#paginate" do

    before do
      @context = stub.quacks_like(Mongoid::Contexts::Mongo.allocate)
      @criteria.instance_variable_set(:@context, @context)
    end

    it "delegates to the context" do
      @context.expects(:paginate).returns([])
      @criteria.paginate.should == []
    end

  end

  describe "#per_page" do

    before do
      @context = stub.quacks_like(Mongoid::Contexts::Mongo.allocate)
      @criteria.instance_variable_set(:@context, @context)
    end

    it "delegates to the context" do
      @context.expects(:per_page).returns(20)
      @criteria.per_page.should == 20
    end

  end

  describe "#scoped" do

    before do
      @criteria = Person.where(:title => "Sir").skip(20)
    end

    it "returns the selector plus the options" do
      @criteria.scoped.should ==
        { :where => { :title => "Sir", :_type=>{ "$in" => [ "Doctor", "Person" ] } }, :skip => 20 }
    end

  end

  describe "#sum" do

    before do
      @context = stub.quacks_like(Mongoid::Contexts::Mongo.allocate)
      @criteria.instance_variable_set(:@context, @context)
    end

    it "delegates to the context" do
      @context.expects(:sum).with(:field).returns(20)
      @criteria.sum(:field).should == 20
    end

  end

  describe ".translate" do

    context "with a single argument" do

      before do
        @id = Mongo::ObjectID.new.to_s
        @document = stub
        @criteria = mock
        Mongoid::Criteria.expects(:new).returns(@criteria)
        @criteria.expects(:id).with(@id).returns(@criteria)
      end

      it "creates a criteria for a string" do
        @criteria.expects(:one).returns(@document)
        @document.expects(:blank? => false)
        Mongoid::Criteria.translate(Person, @id)
      end

      context "when the document is not found" do

        it "raises an error" do
          @criteria.expects(:one).returns(nil)
          lambda { Mongoid::Criteria.translate(Person, @id) }.should raise_error
        end

      end

    end

    context "multiple arguments" do

      context "when an array of ids" do

        before do
          @ids = []
          @documents = []
          3.times do
            @ids << Mongo::ObjectID.new.to_s
            @documents << stub
          end
          @collection = stub
          Person.expects(:collection).returns(@collection)
        end

        context "when documents are found" do

          it "returns an ids criteria" do
            @collection.expects(:find).with(
              { :_type =>
                { "$in" =>
                  ["Doctor", "Person"]
                },
                :_id =>
                { "$in" => @ids }
            }, {}).returns([{ "_id" => "4", "title" => "Sir", "_type" => "Person" }])
            @criteria = Mongoid::Criteria.translate(Person, @ids)
          end

        end

        context "when documents are not found" do

          it "returns an ids criteria" do
            @collection.expects(:find).with(
              { :_type =>
                { "$in" =>
                  ["Doctor", "Person"]
                },
                :_id =>
                { "$in" => @ids }
            }, {}).returns([])
            lambda { Mongoid::Criteria.translate(Person, @ids) }.should raise_error
          end

        end

      end

      context "when Person, :conditions => {}" do

        before do
          @criteria = Mongoid::Criteria.translate(Person, :conditions => { :title => "Test" })
        end

        it "returns a criteria with a selector from the conditions" do
          @criteria.selector.should == { :_type => { "$in" => ["Doctor", "Person"] }, :title => "Test" }
        end

        it "returns a criteria with klass Person" do
          @criteria.klass.should == Person
        end

      end

      context "when :all, :conditions => {}" do

        before do
          @criteria = Mongoid::Criteria.translate(Person, :conditions => { :title => "Test" })
        end

        it "returns a criteria with a selector from the conditions" do
          @criteria.selector.should == { :_type => { "$in" => ["Doctor", "Person"] }, :title => "Test" }
        end

        it "returns a criteria with klass Person" do
          @criteria.klass.should == Person
        end

      end

      context "when :last, :conditions => {}" do

        before do
          @criteria = Mongoid::Criteria.translate(Person, :conditions => { :title => "Test" })
        end

        it "returns a criteria with a selector from the conditions" do
          @criteria.selector.should == { :_type => { "$in" => ["Doctor", "Person"] }, :title => "Test" }
        end

        it "returns a criteria with klass Person" do
          @criteria.klass.should == Person
        end
      end

      context "when options are provided" do

        before do
          @criteria = Mongoid::Criteria.translate(Person, :conditions => { :title => "Test" }, :skip => 10)
        end

        it "adds the criteria and the options" do
          @criteria.selector.should == { :_type => { "$in" => ["Doctor", "Person"] }, :title => "Test" }
          @criteria.options.should == { :skip => 10 }
        end

      end

    end

  end

  context "#fuse" do

    it ":where => {:title => 'Test'} returns a criteria with the correct selector" do
      @result = @criteria.fuse(:where => { :title => 'Test' })
      @result.selector[:title].should == 'Test'
    end

    it ":where => {:title => 'Test'}, :skip => 10 returns a criteria with the correct selector and options" do
      @result = @criteria.fuse(:where => { :title => 'Test' }, :skip => 10)
      @result.selector[:title].should == 'Test'
      @result.options.should == { :skip => 10 }
    end
  end

end
