require File.dirname(__FILE__) + '/../spec_helper'

describe WpPost do
  it "should have an array of tags" do
    WpPost.new.tags.should == []
  end
  it "should have an array of categories" do
    WpPost.new.categories.should == []
  end
end