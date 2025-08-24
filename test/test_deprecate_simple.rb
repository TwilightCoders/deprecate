require 'test/unit'
require 'stringio'
require_relative '../lib/deprecate'

class TestDeprecate < Test::Unit::TestCase
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

  def test_basic_deprecation
    klass = Class.new do
      def old_method
        "old result"
      end

      deprecate :old_method, :new_method
    end

    obj = klass.new
    result = obj.old_method

    assert_equal "old result", result
    assert_match(/DEPRECATION WARNING: old_method is deprecated/, @output.string)
  end

  def test_deprecation_without_replacement
    klass = Class.new do
      def legacy_method
        "legacy"
      end

      deprecate :legacy_method
    end

    obj = klass.new
    result = obj.legacy_method

    assert_equal "legacy", result
    assert_match(/DEPRECATION WARNING: legacy_method is deprecated/, @output.string)
    refute_match(/use .* instead/, @output.string)
  end

  def test_method_with_arguments
    klass = Class.new do
      def old_method(arg1, arg2)
        "#{arg1}-#{arg2}"
      end

      deprecate :old_method
    end

    obj = klass.new
    result = obj.old_method("hello", "world")

    assert_equal "hello-world", result
    assert_match(/DEPRECATION WARNING/, @output.string)
  end

  def test_warn_once_functionality
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
end