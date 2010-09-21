require "spec_helper"

describe Mongoid::Associations::BelongsTo do

  let(:child) do
    Name.new(:first_name => "Drexel", :last_name => "Spivey")
  end

  let(:target) do
    Person.new(:title => "Pimp")
  end

  let(:options) do
    Mongoid::Associations::Options.new(:name => :person, :inverse_of => :name)
  end

  let(:has_many_options) do
    Mongoid::Associations::Options.new(:name => :person, :inverse_of => :addresses)
  end

  describe "#find" do

    before do
      @association = Mongoid::Associations::BelongsTo.new(target, options)
    end

    context "when finding by id" do

      it "always returns the target document" do
        @association.find("").should == target
      end

    end

  end

  describe "#initialize" do

    before do
      @association = Mongoid::Associations::BelongsTo.new(target, options)
    end

    it "sets the target" do
      @association.target.should == target
    end

    it "sets the options" do
      @association.options.should == options
    end

  end

  describe "#initialize" do

    before do
      @parent = Person.new(:title => "Dr")
      @name = Name.new(:first_name => "Richard", :last_name => "Dawkins")
      @parent.name = @name
      @block = Proc.new {
        def extension
          "Testing"
        end
      }
      @options = Mongoid::Associations::Options.new(:name => :person, :extend => @block)
      @association = Mongoid::Associations::BelongsTo.new(@parent, @options)
    end

    context "when the options have an extension" do

      it "adds the extension module" do
        @association.extension.should == "Testing"
      end

    end

  end

  describe ".instantiate" do

    context "when parent exists" do

      before do
        @parent = stub
        @target = stub(:_parent => @parent)
        @association = Mongoid::Associations::BelongsTo.instantiate(@target, options)
      end

      it "sets the parent to the target" do
        @association.target.should == @parent
      end

    end

    context "when parent is nil" do

      before do
        @document = stub(:_parent => nil)
      end

      it "returns nil" do
        Mongoid::Associations::BelongsTo.instantiate(@document, options).should be_nil
      end

    end

  end

  describe ".macro" do

    it "returns :belongs_to" do
      Mongoid::Associations::BelongsTo.macro.should == :belongs_to
    end

  end

  describe "#method_missing" do

    before do
      @association = Mongoid::Associations::BelongsTo.new(target, options)
    end

    context "when method is a getter" do

      it "delegates to the target" do
        @association.title.should == "Pimp"
      end

    end

    context "when method is a setter" do

      before do
        @association.title = "Dealer"
      end

      it "delegates to the target" do
        @association.title.should == "Dealer"
      end

    end

    context "when method does not exist" do

      it "raises an error" do
        lambda { @association.nothing }.should raise_error(NoMethodError)
      end

    end

  end

  describe ".update" do

    context "when child is a has one" do

      before do
        @name = Name.new(:first_name => "Test", :last_name => "User")
        @person = Person.new(:title => "Mrs")
        @association = Mongoid::Associations::BelongsTo.update(@person, @name, options)
      end

      it "updates the parent document" do
        @person.name.should == @name
      end

      it "updates the parent attributes" do
        @person.attributes[:name].except(:_id).should ==
          { "first_name" => "Test", "last_name" => "User", "_type" => "Name" }
      end

      it "returns the proxy association" do
        @association.target.should == @person
      end

    end

    context "when child is a has many" do

      before do
        @address = Address.new(:street => "Broadway")
        @person = Person.new(:title => "Mrs")
        Mongoid::Associations::BelongsTo.update(@person, @address, has_many_options)
      end

      it "updates the parent document" do
        @person.addresses.first.should == @address
      end

    end

  end

end
