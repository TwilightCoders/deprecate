require 'minitest/autorun'
require_relative '../lib/deprecate'

class TestDeprecate < Minitest::Test
  def setup
    Deprecate.reset_warnings!
    @output = StringIO.new
    Deprecate.configure do |config|
      config[:output_stream] = @output
      config[:warn_once] = false
    end
  end

  def teardown
    Deprecate.configure do |config|
      config[:output_stream] = $stderr
      config[:warn_once] = true
    end
  end

  def test_deprecate_method_with_replacement
    klass = Class.new do
      def old_method
        "old result"
      end

      def new_method
        "new result"
      end

      deprecate :old_method, :new_method
    end

    obj = klass.new
    result = obj.old_method

    assert_equal "old result", result
    assert_match(/DEPRECATION WARNING: old_method is deprecated \(use new_method instead\)/,
                 @output.string)
  end

  def test_deprecate_method_without_replacement
    klass = Class.new do
      def old_method
        "old result"
      end

      deprecate :old_method
    end

    obj = klass.new
    result = obj.old_method

    assert_equal "old result", result
    assert_match(/DEPRECATION WARNING: old_method is deprecated\. Called from/, @output.string)
    refute_match(/use .* instead/, @output.string)
  end

  def test_deprecate_with_arguments
    klass = Class.new do
      def old_method(arg1, arg2)
        "#{arg1}-#{arg2}"
      end

      deprecate :old_method, :new_method
    end

    obj = klass.new
    result = obj.old_method("hello", "world")

    assert_equal "hello-world", result
    assert_match(/DEPRECATION WARNING/, @output.string)
  end

  def test_deprecate_preserves_method_scope
    klass = Class.new do
      private

      def private_method
        "private result"
      end

      deprecate :private_method

      public

      def call_private
        private_method
      end
    end

    obj = klass.new
    result = obj.call_private

    assert_equal "private result", result
    assert_raises(NoMethodError) { obj.private_method }
  end

  def test_warn_once_configuration
    Deprecate.configure { |config| config[:warn_once] = true }

    klass = Class.new do
      def old_method
        "result"
      end

      deprecate :old_method
    end

    obj = klass.new
    obj.old_method
    obj.old_method

    assert_equal 1, @output.string.scan(/DEPRECATION WARNING/).length
  end

  def test_reset_warnings
    Deprecate.configure { |config| config[:warn_once] = true }

    klass = Class.new do
      def old_method
        "result"
      end

      deprecate :old_method
    end

    obj = klass.new
    obj.old_method
    Deprecate.reset_warnings!
    obj.old_method

    assert_equal 2, @output.string.scan(/DEPRECATION WARNING/).length
  end

  def test_invalid_symbol_argument
    klass = Class.new

    assert_raises(ArgumentError, "deprecate() requires symbols for its first argument.") do
      klass.class_eval do
        deprecate "string_method"
      end
    end
  end

  def test_custom_message_format
    original_format = Deprecate.config[:message_format]
    Deprecate.configure do |config|
      config[:message_format] = "CUSTOM: %{method} is old%{replacement}"
      config[:show_caller] = false
    end

    klass = Class.new do
      def old_method
        "result"
      end

      deprecate :old_method, :new_method
    end

    obj = klass.new
    obj.old_method

    assert_match(/CUSTOM: old_method is old \(use new_method instead\)/, @output.string)

    Deprecate.configure { |config| config[:message_format] = original_format }
  end
end
