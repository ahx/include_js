require 'v8'
require 'forwardable'

module IncludeJS  
  class << self
    extend Forwardable
    def_delegators :instance, :engine, :module, :modules, :require, :root_path, :root_path=
  end
    
  def self.instance
    @instance ||= Env.new
  end
  
  class Env
    attr_accessor :root_path # FIXME Make this act like a PATH (see Modules 1.1 require.paths) and think about the API
    attr_reader :engine, :modules
    
    def initialize
      @root_path = File.expand_path('.')
      @modules = {} # This stores all loaded modules by their absolute path (not their id)
      @engine = V8::Context.new
    end
    
    def require(module_id)
      load_module(module_id, nil)
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
    
    def load_module(module_id, caller_path)
      path = absolute_path(module_id, caller_path)
      key = module_id.start_with?('.') ? path.chomp(File.extname(path)) : module_id
      return @modules[key] if @modules[key]
      source = File.read(path) # Fails louldly if file does not exist
      exports = @modules[key] = @engine['Object'].new
      
      context = @engine.eval("(function(exports, require){ #{source}})", path)
      context.call(exports, lambda { |module_id| load_module(module_id, path) })
      exports
    end
    
    def absolute_path(module_id, caller_path)
      root = (module_id.start_with?('.') && caller_path) ? File.dirname(caller_path) : @root_path
      File.expand_path("#{root}/#{module_id}.js")
    end
        
  end
  
end