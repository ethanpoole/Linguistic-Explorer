require 'spec_helper'

describe Group do
  describe "one-liners" do
    it { should validate_presence_of :name }
    it { should validate_uniqueness_of :name }
    it { should validate_numericality_of(:depth_maximum) }
    # Activate this instead of the one above, with the new version of shoulda-matchers
    # it { should validate_numericality_of(:depth_maximum).less_than(Group::MAXIMUM_ASSIGNABLE_DEPTH) }
    it { should have_many :lings }
    it { should have_many :lings_properties }
    it { should have_many :examples_lings_properties }
    it { should have_many :examples }
    it { should have_many :categories }
    it { should have_many :memberships }
    it { should have_many :members }
    it { should have_many :searches }
    # it_should_validate_presence_of :name
    # it_should_validate_uniqueness_of :name
    # it_should_validate_numericality_of :depth_maximum, :<= => Group::MAXIMUM_ASSIGNABLE_DEPTH
    # it_should_have_many :lings, :properties, :lings_properties, :examples_lings_properties, :examples, :categories, :memberships, :members, :searches
  end

  describe "should be createable" do
    it "with a name and depth max and privacy" do
      # Also here, waiting for a better macro...
      # should_be_createable :with => { :name => 'myfirstgroup', :depth_maximum => 0, :privacy => Group::PUBLIC }
      expect { Group.create :name => 'myfirstgroup', :depth_maximum => 0, :privacy => Group::PUBLIC }.not_to raise_error
    end
  end

  describe "#ling_name_for_depth" do
    it "should return the level 0 ling name when passed a 0" do
      Group.new(:name => "foo",
                :depth_maximum => 0,
                :privacy => Group::PRIVATE,
                :ling0_name => "foo_0").ling_name_for_depth(0).should == "foo_0"
    end

    it "should return the level 1 ling name when passed a 1" do
      Group.new(:name => "bar",
                :depth_maximum => 1,
                :privacy => Group::PUBLIC,
                :ling1_name => "bar_1").ling_name_for_depth(1).should == "bar_1"
    end

    it "should raise an exception with an out of bounds depth argument" do
      lambda do
        Group.new(:name => "baz", :depth_maximum => 0, :privacy => Group::PRIVATE, :ling1_name => "huehue").ling_name_for_depth(1)
      end.should raise_exception
    end
  end

  describe "#ling_names" do
    it "should return an array with ling0 name only if in a single depth group" do
      Group.new(:name => "foo", :privacy => Group::PRIVATE, :depth_maximum => 0, :ling0_name => "foo").ling_names.should == ["foo"]
    end

    it "should return an array with ling0 and ling1 name if in a multi depth group" do
      Group.new(:name => "foo", :privacy => Group::PRIVATE, :depth_maximum => 1, :ling0_name => "foo", :ling1_name => "bar").ling_names.should == ["foo", "bar"]
    end
  end

  describe "#depths" do
    it "should return an array [0] to a no depth group" do
      FactoryGirl.create(:group, :depth_maximum => 0).depths.should == [ 0 ]
    end

    it "should return an array of the available depths to the group" do
      FactoryGirl.create(:group, :depth_maximum => 1).depths.should == [0, 1]
    end
  end

  describe "#example_storable_keys" do
    it "should by default have the key 'description'" do
      Group.new.example_storable_keys.should include 'description'
    end

    describe "should return an array of strings created from example_fields" do
      it "that has only default keys if the field is empty" do
        FactoryGirl.create(:group, :example_fields => "").example_storable_keys.should == ['description']
      end

      it "should ignore duplicates" do
        FactoryGirl.create(:group, :example_fields => "description, foo, foo").example_storable_keys.should == ["description", "foo"]
      end

      it "that splits on commas if fields has any" do
        FactoryGirl.create(:group, :example_fields => "foo,bar").example_storable_keys.should == [ "description", "foo", "bar"]
      end

      it "that strips leading and trailing whitespace from all values" do
        FactoryGirl.create(:group, :example_fields => " foo , bar ").example_storable_keys.should == [ "description", "foo", "bar"]
      end
    end
  end

  describe "#ling_storable_keys" do
    it "should by default have description" do
      Group.new.ling_storable_keys.should include 'description'
    end

    describe "should return an array of strings created from example_fields" do
      it "that has only default keys if the field is empty" do
        FactoryGirl.create(:group, :ling_fields => "").ling_storable_keys.should == ['description']
      end

      it "should ignore duplicates" do
        FactoryGirl.create(:group, :ling_fields => "description, foo, foo").ling_storable_keys.should == ["description", "foo"]
      end

      it "that splits on commas if fields has any" do
        FactoryGirl.create(:group, :ling_fields => "foo,bar").ling_storable_keys.should == ["description", "foo", "bar"]
      end

      it "that strips leading and trailing whitespace from all values" do
        FactoryGirl.create(:group, :ling_fields => " foo , bar ").ling_storable_keys.should == ["description", "foo", "bar"]
      end
    end
  end
end
