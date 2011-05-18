# IncludeJS

This is an experiment to see if we can use CommonJS Modules inside Ruby.

Currently it supports the [CommonJS Modules 1.0 spec](http://www.commonjs.org/specs/modules/1.0/).

It uses [therubyracer](github.com/cowboyd/therubyracer).

## Synopsis

### Writing a CommonJS Module in JavaScript
Inside 'helpers.js':

    var a = 42;
    exports.foo = function() {
      return 42;
    }

### Loading a CommonJS Module from Ruby
    helpers = IncludeJS.require('helpers') # This returns a V8::Object
    helpers.foo # => 42

### Loading a CommonJS Module as a Ruby Module
    class App
      include IncludeJS.module('helpers')
    end
    App.new.foo # => 42

You can set one root path from where to load .js files

    IncludeJS.root_path = 'my/app/javascripts'

Have fun.

## Running the specs
    git submodule update --init
    bundle install
    bundle rspec spec    

## Speed
Simple benchmarks are showing a noticeable gain of speed when using JS methods
instead of native Ruby ones. While the Google V8 seems to be 10x faster than 
Ruby 1.8.7 it is still 4x as fast as Ruby 1.9.2

