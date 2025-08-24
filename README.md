# Deprecate

[![CI](https://github.com/twilightcoders/deprecate/actions/workflows/ci.yml/badge.svg)](https://github.com/twilightcoders/deprecate/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/deprecate.svg)](https://badge.fury.io/rb/deprecate)
[![Code Quality](https://img.shields.io/badge/code%20quality-qlty-blue)](https://qlty.sh)

Easily maintain your codebase by exposing an easy and concise way to mark methods as deprecated.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'deprecate'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install deprecate

## Usage

### Basic Usage

Simply call `deprecate` with the method name you want to deprecate:

```ruby
class MyClass
  def old_method
    "This method still works but is deprecated"
  end
  
  def new_method
    "This is the new way"
  end
  
  # Mark old_method as deprecated and suggest new_method
  deprecate :old_method, :new_method
end

obj = MyClass.new
obj.old_method  # Works but prints deprecation warning
# => DEPRECATION WARNING: old_method is deprecated (use new_method instead). Called from example.rb:15
```

### Without Replacement Suggestion

```ruby
class MyClass
  def legacy_method
    "Going away soon"
  end
  
  # Mark as deprecated without suggesting replacement
  deprecate :legacy_method
end

obj = MyClass.new
obj.legacy_method  # Prints: DEPRECATION WARNING: legacy_method is deprecated. Called from example.rb:10
```

### Configuration

Configure deprecation behavior globally:

```ruby
Deprecate.configure do |config|
  config[:output_stream] = File.open('deprecations.log', 'a')  # Log to file instead of stderr
  config[:message_format] = "WARNING: %{method} is deprecated%{replacement}"  # Custom message format
  config[:show_caller] = false  # Don't show caller location
  config[:warn_once] = false    # Warn every time, not just once per method
end
```

### Configuration Options

- **`:output_stream`** - Where to send warnings (default: `$stderr`)
- **`:message_format`** - Message template with `%{method}`, `%{replacement}`, `%{caller}` placeholders
- **`:show_caller`** - Include caller location in warnings (default: `true`)
- **`:warn_once`** - Only warn once per deprecated method (default: `true`)

### Resetting Warnings

Clear the "warned once" tracking to see warnings again:

```ruby
Deprecate.reset_warnings!
```

### Method Visibility

The gem preserves the original method's visibility (public, protected, private):

```ruby
class MyClass
  private
  
  def secret_method
    "private stuff"
  end
  
  deprecate :secret_method
  
  public
  
  def call_secret
    secret_method  # This works and shows deprecation warning
  end
end

obj = MyClass.new
obj.call_secret      # Works
obj.secret_method    # Still raises NoMethodError (method remains private)
```

## Contributing

1. Fork it ( https://github.com/twilightcoders/deprecate/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
