require "spec_helper"

describe Mongoid::Criterion::Inclusion do

  before do
    @criteria = Mongoid::Criteria.new(Person)
    @canvas_criteria = Mongoid::Criteria.new(Canvas)
  end

  describe "#all" do

    it "adds the $all query to the selector" do
      @criteria.all(:title => ["title1", "title2"])
      @criteria.selector.should ==
        { :_type => { "$in" => ["Doctor", "Person"] },
          :title => { "$all" => ["title1", "title2"] }
        }
    end

    it "returns self" do
      @criteria.all(:title => [ "title1" ]).should == @criteria
    end

  end

  describe "#and" do

    context "when provided a hash" do

      it "adds the clause to the selector" do
        @criteria.and(:title => "Title", :text => "Text")
        @criteria.selector.should ==
          { :_type => { "$in" => ["Doctor", "Person"] },
            :title => "Title",
            :text => "Text"
          }
      end

    end

    context "when provided a string" do

      it "adds the $where clause to the selector" do
        @criteria.and("this.date < new Date()")
        @criteria.selector.should ==
          { :_type => { "$in" => ["Doctor", "Person"] },
            "$where" => "this.date < new Date()"
          }
      end

    end

    it "returns self" do
      @criteria.and.should == @criteria
    end

  end

  describe "#in" do

    it "adds the $in clause to the selector" do
      @criteria.in(:title => ["title1", "title2"], :text => ["test"])
      @criteria.selector.should ==
        { :_type =>
          { "$in" =>
            ["Doctor", "Person"]
          }, :title => { "$in" => ["title1", "title2"] }, :text => { "$in" => ["test"] }
        }
    end

    it "returns self" do
      @criteria.in(:title => ["title1"]).should == @criteria
    end

  end

  describe "#where" do

    context "when provided a hash" do

      context "with simple hash keys" do

        it "adds the clause to the selector" do
          @criteria.where(:title => "Title", :text => "Text")
          @criteria.selector.should ==
            { :_type => { "$in" => ["Doctor", "Person"] }, :title => "Title", :text => "Text" }
        end

      end

      context "with complex criterion" do

        context "#all" do

          it "returns those matching an all clause" do
            @criteria.where(:title.all => ["Sir"])
            @criteria.selector.should ==
              { :_type => { "$in" => ["Doctor", "Person"] }, :title => { "$all" => ["Sir"] } }
          end

        end

        context "#exists" do

          it "returns those matching an exists clause" do
            @criteria.where(:title.exists => true)
            @criteria.selector.should ==
              { :_type => { "$in" => ["Doctor", "Person"] }, :title => { "$exists" => true } }
          end

        end

        context "#gt" do

          it "returns those matching a gt clause" do
            @criteria.where(:age.gt => 30)
            @criteria.selector.should ==
              { :_type => { "$in" => ["Doctor", "Person"] }, :age => { "$gt" => 30 } }
          end

        end

        context "#gte" do

          it "returns those matching a gte clause" do
            @criteria.where(:age.gte => 33)
            @criteria.selector.should ==
              { :_type => { "$in" => ["Doctor", "Person"] }, :age => { "$gte" => 33 } }
          end

        end

        context "#in" do

          it "returns those matching an in clause" do
            @criteria.where(:title.in => ["Sir", "Madam"])
            @criteria.selector.should ==
              { :_type => { "$in" => ["Doctor", "Person"] }, :title => { "$in" => ["Sir", "Madam"] } }
          end

        end

        context "#lt" do

          it "returns those matching a lt clause" do
            @criteria.where(:age.lt => 34)
            @criteria.selector.should ==
              { :_type => { "$in" => ["Doctor", "Person"] }, :age => { "$lt" => 34 } }
          end

        end

        context "#lte" do

          it "returns those matching a lte clause" do
            @criteria.where(:age.lte => 33)
            @criteria.selector.should ==
              { :_type => { "$in" => ["Doctor", "Person"] }, :age => { "$lte" => 33 } }
          end

        end

        context "#ne" do

          it "returns those matching a ne clause" do
            @criteria.where(:age.ne => 50)
            @criteria.selector.should ==
              { :_type => { "$in" => ["Doctor", "Person"] }, :age => { "$ne" => 50 } }
          end

        end

        context "#nin" do

          it "returns those matching a nin clause" do
            @criteria.where(:title.nin => ["Esquire", "Congressman"])
            @criteria.selector.should ==
              { :_type => { "$in" => ["Doctor", "Person"] }, :title => { "$nin" => ["Esquire", "Congressman"] } }
          end

        end

        context "#size" do

          it "returns those matching a size clause" do
            @criteria.where(:aliases.size => 2)
            @criteria.selector.should ==
              { :_type => { "$in" => ["Doctor", "Person"] }, :aliases => { "$size" => 2 } }
          end

        end

      end

    end

    context "when provided a string" do

      it "adds the $where clause to the selector" do
        @criteria.where("this.date < new Date()")
        @criteria.selector.should ==
          { :_type => { "$in" => ["Doctor", "Person"] }, "$where" => "this.date < new Date()" }
      end

    end

    it "returns self" do
      @criteria.where.should == @criteria
    end

  end

end
