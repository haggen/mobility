module Mobility
=begin

Defines methods for attaching backends to a class. A block can optionally be
passed to accessors to configure backend (see example below).

@example Defining backend on a class
  class MyClass
    extend Translates
    mobility_accessor :foo, option: :value
  end

@example Passing backend to a block
  class MyClass
    extend Translates
    mobility_accessor :foo, option: :value do
      # add custom code to backend class for this attribute only
    end
  end

@example Defining only a backend reader and presence method
  class MyClass
    extend Translates
    mobility_reader :foo
  end

  instance = MyClass.new
  instance.foo         #=> (some value)
  instance.foo?        #=> true
  instance.foo = "foo" #=> NoMethodError

@example Defining only a backend writer
  class MyClass
    extend Translates
    mobility_writer :foo
  end

  instance = MyClass.new
  instance.foo         #=> NoMethodError
  instance.foo?        #=> NoMethodError
  instance.foo = "foo" #=> (sets attribute to value "foo")
=end
  module Translates
    # Defines mobility accessor on model class.
    # @param [Array<String>] attributes
    # @param [Hash] options
    # @yield Yields to block with backend as context
    # @!method mobility_accessor(*attributes, **options)

    # Defines mobility reader and presence method on model class.
    # @param [Array<String>] attributes
    # @param [Hash] options
    # @yield Yields to block with backend as context
    # @!method mobility_reader(*attributes, **options)

    # Defines mobility writer on model class.
    # @param [Array<String>] attributes
    # @param [Hash] options
    # @yield Yields to block with backend as context
    # @!method mobility_writer(*attributes, **options)
    %w[accessor reader writer].each do |method|
      class_eval <<-EOM, __FILE__, __LINE__ + 1
        def mobility_#{method}(*args, **options, &block)
          attributes = Attributes.new(:#{method}, *args, options.merge(model_class: self))
          attributes.backend.instance_eval(&block) if block_given?
          attributes.each do |attribute|
            alias_method "\#{attribute}_before_mobility",  attribute        if method_defined?(attribute)        && #{%w[accessor reader].include? method}
            alias_method "\#{attribute}_before_mobility=", "\#{attribute}=" if method_defined?("\#{attribute}=") && #{%w[accessor writer].include? method}
           end
          include attributes
        end
      EOM
    end
  end
end
