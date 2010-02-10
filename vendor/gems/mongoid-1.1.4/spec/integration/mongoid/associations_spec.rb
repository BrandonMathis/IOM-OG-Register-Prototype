require "spec_helper"

describe Mongoid::Associations do

  before do
    Person.delete_all
    Game.delete_all
    Post.delete_all
  end

  context "anonymous extensions" do

    before do
      @person = Person.new(:title => "Dr")
      @address_one = Address.new(:street => "Oxford")
      @address_two = Address.new(:street => "Bond")
      @name = Name.new(:first_name => "Richard", :last_name => "Dawkins")
      @person.addresses << [ @address_one, @address_two ]
      @person.name = @name
      @person.save
    end

    context "when defined on a has_many" do

      it "applies the extension" do
        addresses = @person.addresses.find_by_street("Oxford")
        addresses.size.should == 1
        addresses.first.should == @address_one
      end

    end

    context "when defined on a has_one" do

      it "applies the extension" do
        name = @person.name
        name.dawkins?.should be_true
      end

    end

    context "when defined on a belongs_to" do

      it "applies the extension" do
        @address_two.addressable.doctor?.should be_true
      end

    end

  end

  context "criteria on has many embedded associations" do

    before do
      @person = Person.new(:title => "Sir")
      @sf_apartment = Address.new(:street => "Genoa Pl", :state => "CA", :address_type => "Apartment")
      @la_home = Address.new(:street => "Rodeo Dr", :state => "CA", :address_type => "Home")
      @sf_home = Address.new(:street => "Pacific", :state => "CA", :address_type => "Home")
      @person.addresses << [ @sf_apartment, @la_home, @sf_home ]
    end

    it "handles a single criteria" do
      cas = @person.addresses.california
      cas.size.should == 3
      cas.should == [ @sf_apartment, @la_home, @sf_home ]
    end

    it "handles chained criteria" do
      ca_homes = @person.addresses.california.homes
      ca_homes.size.should == 2
      ca_homes.should == [ @la_home, @sf_home ]
    end

    it "handles chained criteria with named scopes" do
      ca_homes = @person.addresses.california.homes.rodeo
      ca_homes.size.should == 1
      ca_homes.should == [ @la_home ]
    end

  end

  context "one-to-one relational associations" do

    before do
      @person = Person.new(:title => "Sir")
      @game = Game.new(:score => 1)
      @person.game = @game
      @person.save
    end

    it "sets the association on save" do
      @from_db = Person.find(@person.id)
      @from_db.game.should == @game
    end

    it "sets the reverse association before save" do
      @game.person.should == @person
    end

    it "sets the reverse association after save" do
      @from_db = Game.find(@game.id)
      @game.person.should == @person
    end

  end

  context "one-to-many relational associations" do

    before do
      @person = Person.new(:title => "Sir")
      @post = Post.new(:title => "Testing")
      @person.posts = [@post]
      @person.save
    end

    it "sets the association on save" do
      from_db = Person.find(@person.id)
      from_db.posts.should == [@post]
    end

    context "when building" do

      before do
        @person = Person.new(:title => "Mr")
        @post = @person.posts.build(:title => "First")
      end

      it "sets the reverse association" do
        @post.person.should == @person
      end

    end

    context "finding associated objects" do

      before do
        @extra_post = Post.create(:title => "Orphan")
        @from_db = Person.find(@person.id)
      end

      context "finding all" do

        it "returns only those objects scoped to the parent" do
          Post.all.size.should == 2
          @from_db.posts.all.size.should == 1
        end

      end

      context "finding with conditions" do

        context "finding all" do

          it "returns only those objects scoped to the parent" do
            posts = @from_db.posts.find(:all, :conditions => { :title => "Testing" })
            posts.size.should == 1
          end

        end

        context "finding first" do

          it "returns only those objects scoped to the parent" do
            post = @from_db.posts.find(:first, :conditions => { :title => "Testing" })
            post.should == @post
          end

        end

        context "finding last" do

          it "returns only those objects scoped to the parent" do
            post = @from_db.posts.find(:last, :conditions => { :title => "Testing" })
            post.should == @post
          end

        end

        context "using a named scope" do

          before do
            @post.created_at = 15.days.ago
            @post.save
          end

          it "returns only those scoped to the parent plus the named scope" do
            posts = @from_db.posts.recent
            posts.size.should == 1
          end

        end

        context "using a criteria class method" do

          before do
            @post.created_at = 45.days.ago
            @post.save
          end

          it "returns only those scoped to the parent plus the named scope" do
            posts = @from_db.posts.old
            posts.size.should == 1
          end

        end

      end

    end

  end

  context "nested embedded associations" do

    before do
      @person = Person.create(:title => "Mr")
    end

    context "one level nested" do

      before do
        @address = @person.addresses.create(:street => "Oxford St")
        @name = @person.create_name(:first_name => "Gordon")
      end

      it "persists all the associations properly" do
        @name.last_name = "Brown"
        @person.name.last_name.should == "Brown"
      end

    end

    context "multiple levels nested" do

      context "when a has-many to has_one" do

        before do
          @person.phone_numbers.create(:number => "4155551212")
        end

        it "persists all the associations properly" do
          from_db = Person.find(@person.id)
          phone = from_db.phone_numbers.first
          phone.create_country_code(:code => 1)
          from_db.phone_numbers.first.country_code.code.should == 1
        end

      end

      context "when a has-one to has-many" do

        before do
          @person = Person.new(:title => "Sir", :ssn => "1")
          @name = Name.new(:first_name => "Syd")
          @person.name = @name
          @person.save
        end

        it "persists all the associations properly" do
          from_db = Person.find(@person.id)
          translation = Translation.new(:language => "fr")
          from_db.name.translations << translation
          from_db.attributes[:name][:translations].should_not be_nil
        end

      end

      context "when a has-many to has-many" do

        before do
          @address = Address.new(:street => "Upper Street")
          @person.addresses << @address
        end

        it "bubbles the child association up to root" do
          location = Location.new(:name => "Home")
          @address.locations << location
          location.stubs(:valid?).returns(false)
          @person.save
          @person.addresses.first.locations.first.should == location
        end

      end

    end

  end

end
