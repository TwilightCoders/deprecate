#!/usr/bin/env ruby
require 'stringio'
require_relative '../lib/deprecate'

def assert_equal(expected, actual, message = nil)
  unless expected == actual
    raise "Assertion failed#{message ? ": #{message}" : ""}\n  Expected: #{expected.inspect}\n  Actual: #{actual.inspect}"
  end
end

def assert_match(pattern, string, message = nil)
  unless pattern.match?(string)
    raise "Assertion failed#{message ? ": #{message}" : ""}\n  Pattern: #{pattern.inspect}\n  String: #{string.inspect}"
  end
end

def refute_match(pattern, string, message = nil)
  if pattern.match?(string)
    raise "Assertion failed#{message ? ": #{message}" : ""}\n  Pattern should NOT match: #{pattern.inspect}\n  String: #{string.inspect}"
  end
end

# Setup
def setup_test
  Deprecate.reset_warnings!
  output = StringIO.new
  Deprecate.configure do |config|
    config[:output_stream] = output
    config[:warn_once] = false
  end
  output
end

def teardown_test
  Deprecate.configure do |config|
    config[:output_stream] = $stderr
    config[:warn_once] = true
  end
end

puts "Running basic deprecation tests..."

# Test 1: Basic deprecation
output = setup_test

klass = Class.new do
  def old_method
    "old result"
  end

  deprecate :old_method, :new_method
end

obj = klass.new
result = obj.old_method

assert_equal "old result", result
assert_match(/DEPRECATION WARNING: old_method is deprecated/, output.string)
puts "✓ Basic deprecation test passed"

teardown_test

# Test 2: Without replacement
output = setup_test

klass2 = Class.new do
  def legacy_method
    "legacy"
  end

  deprecate :legacy_method
end

obj2 = klass2.new
result2 = obj2.legacy_method

assert_equal "legacy", result2
assert_match(/DEPRECATION WARNING: legacy_method is deprecated/, output.string)
refute_match(/use .* instead/, output.string)
puts "✓ Deprecation without replacement test passed"

teardown_test

# Test 3: Method with arguments
output = setup_test

klass3 = Class.new do
  def old_method(arg1, arg2)
    "#{arg1}-#{arg2}"
  end

  deprecate :old_method
end

obj3 = klass3.new
result3 = obj3.old_method("hello", "world")

assert_equal "hello-world", result3
assert_match(/DEPRECATION WARNING/, output.string)
puts "✓ Method with arguments test passed"

teardown_test

# Test 4: Warn once functionality
output = setup_test
Deprecate.configure { |config| config[:warn_once] = true }

klass4 = Class.new do
  def old_method
    "result"
  end

  deprecate :old_method
end

obj4 = klass4.new
obj4.old_method
obj4.old_method

warnings_count = output.string.scan(/DEPRECATION WARNING/).length
assert_equal 1, warnings_count
puts "✓ Warn once functionality test passed"

teardown_test

puts "\nAll tests passed! ✅"