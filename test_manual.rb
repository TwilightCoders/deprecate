#!/usr/bin/env ruby
require_relative 'lib/deprecate'

# Simple test to verify the gem works
class TestClass
  def old_method(name = "world")
    "Hello, #{name}!"
  end
  
  def new_method(name = "world") 
    "Hi there, #{name}!"
  end
  
  deprecate :old_method, :new_method
end

puts "Testing basic functionality..."
obj = TestClass.new

puts "Calling deprecated method:"
result = obj.old_method("Claude")
puts "Result: #{result}"

puts "\nCalling again (should warn only once by default):"
result2 = obj.old_method("again")
puts "Result: #{result2}"

puts "\nResetting warnings and calling again:"
Deprecate.reset_warnings!
result3 = obj.old_method("reset")
puts "Result: #{result3}"

puts "\nTesting without replacement:"
class TestClass2
  def legacy_method
    "legacy"
  end
  
  deprecate :legacy_method
end

obj2 = TestClass2.new
result4 = obj2.legacy_method
puts "Legacy result: #{result4}"

puts "\nAll tests completed successfully!"