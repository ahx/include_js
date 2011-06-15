require 'include_js'

describe IncludeJS do
  before(:all) do 
    @root = './spec/support'
    IncludeJS.root_path = @root
  end
  
  describe "require" do
    it "can load a CommonJS module" do
      test_module = IncludeJS.require('test_module')
      act_like_test(test_module)
    end
        
    it "ignores nonexistent files" do
      js = IncludeJS::Env.new
      js.root_path = @root
      lambda {        
        js.require('nonexistent')
      }.should raise_error(Errno::ENOENT)
      js.instance_eval('@modules').keys.should be_empty
    end
  end
  
  describe "modules" do
    it "returns modules by their id" do
      id = 'test_module'
      test_module = IncludeJS.require(id)
      IncludeJS.modules[id].should be_true # truthy      
      act_like_test(test_module)
    end
    
    it "returns nested loaded modules by their absolute path (without extension)" do
      test_module = IncludeJS.require('test_module')
      path = File.expand_path(File.join(@root, 'test_sub_module'))
      IncludeJS.modules.keys.should include(path)
      multi = IncludeJS.modules[path].should be_true
      multi.multiply(2, 2).should == 4
    end
  end
  
  describe "include" do  
    it "can include a CommonJS module" do
      test = Class.new do
        include IncludeJS.module('test_module')
      end.new
      act_like_test(test)
    end
  end
  
  def act_like_test(test)
    test.plus(1, 2).should be 3
    test.minus(1, 2).should be(-1)
    test.minus(2, 1).should be 1
    test.square(4).should be 16
  end  
end