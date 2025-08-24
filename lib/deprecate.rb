require 'deprecate/version'

class DeprecationError < StandardError; end

module Deprecate
  @config = {
    output_stream: $stderr,
    message_format: "DEPRECATION WARNING: %{method} is deprecated%{replacement}. Called from %{caller}",
    show_caller: true,
    warn_once: true
  }

  @warned_methods = {}

  class << self
    attr_reader :config, :warned_methods

    def configure
      yield @config if block_given?
      @config
    end

    def reset_warnings!
      @warned_methods.clear
    end
  end

  module Deprecatable
    def __deprecated_run_action__(method_name, replacement = nil)
      method_key = "#{self.class.name}##{method_name}"

      return if Deprecate.config[:warn_once] && Deprecate.warned_methods[method_key]

      replacement_text = replacement ? " (use #{replacement} instead)" : ""
      caller_info = if Deprecate.config[:show_caller]
                      caller_location = caller_locations(3, 1)
                      caller_location && caller_location.first ? caller_location.first.to_s : "unknown"
                    else
                      "unknown"
                    end

      message = Deprecate.config[:message_format] % {
        method: method_name,
        replacement: replacement_text,
        caller: caller_info
      }

      Deprecate.config[:output_stream].puts(message)
      Deprecate.warned_methods[method_key] = true if Deprecate.config[:warn_once]
    end

    def deprecate(sym, replacement = nil, scope = nil)
      unless sym.is_a?(Symbol)
        raise ArgumentError, 'deprecate() requires symbols for its first argument.'
      end

      meth = instance_method(sym)
      unless scope
        pub = public_instance_methods
        pro = protected_instance_methods
        pri = private_instance_methods
        if pub.include?(sym) || pub.include?(sym.to_s)
          scope = :public
        elsif pro.include?(sym) || pro.include?(sym.to_s)
          scope = :protected
        elsif pri.include?(sym) || pri.include?(sym.to_s)
          scope = :private
        end
      end

      define_method(sym) do |*args|
        __deprecated_run_action__(sym, replacement)
        meth.bind(self).call(*args)
      end

      method(scope).call(sym) if scope
      return scope
    end
  end
end

class Object
  include Deprecate::Deprecatable
end
