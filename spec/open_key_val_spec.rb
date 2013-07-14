require 'spec_helper'
require 'open_key_val'

describe OpenKeyVal do
  before(:all) do
    @post_data = [[Random.rand(200), Random.rand(2000), :test_asdf]]
    @post_data2 = [
      [Random.rand(200), Random.rand(2000), :test_asdf], 
      [Random.rand(100), Random.rand(1000), :test_asdf, :banana]
    ]
    @key_name = 'testspec___' + Random.rand(50000).to_s
  end
  
  describe "uri" do
    context "with a key #{@key_name}" do
      it "should return a valid uri" do
        OpenKeyVal.uri(@key_name).to_s.should eq('http://api.openkeyval.org/' + @key_name)
      end
    end
    
    context "without a key" do
      it "should return a valid uri" do
        OpenKeyVal.uri.to_s.should eq('http://api.openkeyval.org/')
      end
    end
  end
  
  describe "post" do
    it "should post #{@post_data.inspect} to #{@key_name}" do
      response = OpenKeyVal.post @key_name, @post_data
      response.should be_instance_of(Hash)
      response['status'].should eq('multiset')
      response['keys'].should_not be_empty
    end
    
    it "should get #{@key_name} equals #{@post_data}" do
      value = OpenKeyVal.get @key_name
      value.should be_instance_of(Array)
      value.should eq @post_data
    end
    
    it "should post to #{@post_data2} to #{@key_name} again" do
      response = OpenKeyVal.post @key_name, @post_data2
      response.should be_instance_of(Hash)
      response['status'].should eq('multiset')
      response['keys'].should_not be_empty
    end
    
    it "should get #{@key_name} equals #{@post_data2}" do
      value = OpenKeyVal.get @key_name
      value.should be_instance_of(Array)
      value.should eq @post_data2
    end
  end
end