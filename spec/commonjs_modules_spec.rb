require 'include_js'

describe IncludeJS do
  specs = Dir.glob('./spec/support/commonjs/tests/modules/1.0/**')
  raise "Could not load the CommonJS specs. Maybe you need to run 'git submodule update --init'?" if specs.empty?
  
  specs.each { |dir|    
    send 'it', "passes the Modules 1.0 '#{File.basename(dir)}' test" do
      outcome = []
      IncludeJS.engine[:print] = lambda { |*args| outcome << args.first }
      IncludeJS.root_path = dir
      env = IncludeJS.require('program')
      outcome.join.should_not == []
      outcome.join.should_not include 'FAIL'
    end 
    
  }

end