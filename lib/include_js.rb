require 'v8'
require 'forwardable'

module IncludeJS  
  class << self
    extend Forwardable
    def_delegators :instance, :require, :module, :root_path, :root_path=
  end
    
  def self.instance
    @instance ||= Env.new
  end
  
  class Env
    attr_accessor :root_path # FIXME Make this act like a PATH (see Modules 1.1 require.paths) and think about the API
    
    def initialize
      @root_path = File.expand_path('.')
      @modules = {} # This stores all loaded modules by their absolute path (not their id)
      @engine = V8::Context.new
    end
    
    def require(module_id, globals={})
      load_module(module_id, globals, nil)
    end
    
    def module(module_id)
      result = Module.new
      require(module_id).each do |name, method|
        result.send(:define_method, name) do |*args| 
          method.call(*args)
        end
      end
      result
    end
    
    protected
    
    def load_module(module_id, globals, caller_path)
      path = absolute_path(module_id, caller_path)
      return @modules[path] if @modules[path]
      source = File.read(path) # Fails louldly if file does not exist
      globals.each { |name, value| @engine[name] = value } # FIXME Remove. globals is just hax to make the tests pass
      exports = @modules[path] = @engine['Object'].new
      require_fn = lambda { |module_id| load_module(module_id, globals, path) }
      
      context = @engine.eval("(function(exports, require){ #{source}})", path)
      context.call(exports, require_fn)
      exports
    end
    
    def absolute_path(module_id, caller_path)
      root = (module_id.start_with?('.') && caller_path) ? File.dirname(caller_path) : @root_path
      File.expand_path("#{root}/#{module_id}.js")
    end
        
  end
  
end