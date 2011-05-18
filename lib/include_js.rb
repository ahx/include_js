require 'v8'

module IncludeJS
  @root_path = File.expand_path('.')
  @modules = {} # This stores all loaded modules by their absolute path (not their id)
  @cxt = V8::Context.new
  
  class << self
    attr_accessor :root_path # FIXME Make this act like a PATH (see Modules 1.1 require.paths) and think about the API
    
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
      globals.each { |name, value| @cxt[name] = value } # FIXME Remove. globals is just hax to make the tests pass
      exports = @modules[path] = @cxt['Object'].new
      require_fn = lambda { |module_id| load_module(module_id, globals, path) }
      
      context = @cxt.eval("(function(exports, require){ #{File.read(path)}})")
      context.call(exports, require_fn)
      exports
    end
    
    def absolute_path(module_id, caller_path)
      root = (module_id.start_with?('.') && caller_path) ? File.dirname(caller_path) : @root_path
      File.expand_path("#{root}/#{module_id}.js")
    end
        
  end
  
end