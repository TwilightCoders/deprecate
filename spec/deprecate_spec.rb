require 'spec_helper'

RSpec.describe Deprecate do
  let(:output) { StringIO.new }
  
  before do
    Deprecate.reset_warnings!
    Deprecate.configure do |config|
      config[:output_stream] = output
      config[:warn_once] = false
    end
  end
  
  after do
    Deprecate.configure do |config|
      config[:output_stream] = $stderr
      config[:warn_once] = true
    end
  end

  describe '#deprecate' do
    context 'with replacement method' do
      let(:test_class) do
        Class.new do
          def old_method
            "old result"
          end
          
          def new_method
            "new result"
          end
          
          deprecate :old_method, :new_method
        end
      end

      it 'returns the original method result' do
        obj = test_class.new
        expect(obj.old_method).to eq("old result")
      end

      it 'prints deprecation warning with replacement' do
        obj = test_class.new
        obj.old_method
        expect(output.string).to match(/DEPRECATION WARNING: old_method is deprecated \(use new_method instead\)/)
      end
    end

    context 'without replacement method' do
      let(:test_class) do
        Class.new do
          def legacy_method
            "legacy result"
          end
          
          deprecate :legacy_method
        end
      end

      it 'returns the original method result' do
        obj = test_class.new
        expect(obj.legacy_method).to eq("legacy result")
      end

      it 'prints deprecation warning without replacement' do
        obj = test_class.new
        obj.legacy_method
        expect(output.string).to match(/DEPRECATION WARNING: legacy_method is deprecated\./)
        expect(output.string).not_to match(/use .* instead/)
      end
    end

    context 'with method arguments' do
      let(:test_class) do
        Class.new do
          def old_method(arg1, arg2)
            "#{arg1}-#{arg2}"
          end
          
          deprecate :old_method, :new_method
        end
      end

      it 'passes arguments correctly' do
        obj = test_class.new
        expect(obj.old_method("hello", "world")).to eq("hello-world")
      end

      it 'prints deprecation warning' do
        obj = test_class.new
        obj.old_method("hello", "world")
        expect(output.string).to match(/DEPRECATION WARNING/)
      end
    end

    context 'with private methods' do
      let(:test_class) do
        Class.new do
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
      end

      it 'preserves method visibility' do
        obj = test_class.new
        expect(obj.call_private).to eq("private result")
        expect { obj.private_method }.to raise_error(NoMethodError)
      end

      it 'prints deprecation warning when called' do
        obj = test_class.new
        obj.call_private
        expect(output.string).to match(/DEPRECATION WARNING: private_method is deprecated/)
      end
    end

    context 'with invalid arguments' do
      it 'raises ArgumentError for non-symbol arguments' do
        expect {
          Class.new do
            deprecate "string_method"
          end
        }.to raise_error(ArgumentError, /deprecate\(\) requires symbols/)
      end
    end
  end

  describe 'configuration' do
    context 'warn_once setting' do
      before { Deprecate.configure { |config| config[:warn_once] = true } }

      let(:test_class) do
        Class.new do
          def old_method
            "result"
          end
          
          deprecate :old_method
        end
      end

      it 'warns only once per method' do
        obj = test_class.new
        obj.old_method
        obj.old_method
        
        warnings = output.string.scan(/DEPRECATION WARNING/)
        expect(warnings.length).to eq(1)
      end
    end

    context 'custom message format' do
      before do
        Deprecate.configure do |config|
          config[:message_format] = "CUSTOM: %{method} is old%{replacement}"
          config[:show_caller] = false
        end
      end

      let(:test_class) do
        Class.new do
          def old_method
            "result"
          end
          
          deprecate :old_method, :new_method
        end
      end

      it 'uses custom message format' do
        obj = test_class.new
        obj.old_method
        expect(output.string).to match(/CUSTOM: old_method is old \(use new_method instead\)/)
      end
    end
  end

  describe '.reset_warnings!' do
    it 'clears the warned methods hash' do
      # Just test that the hash gets cleared
      Deprecate.configure { |config| config[:warn_once] = true }
      
      # Add a warning to the hash
      test_class = Class.new do
        def old_method
          "result"
        end
        deprecate :old_method
      end
      
      obj = test_class.new
      obj.old_method  # This should add to warned_methods hash
      
      expect(Deprecate.warned_methods).not_to be_empty
      
      Deprecate.reset_warnings!
      expect(Deprecate.warned_methods).to be_empty
    end
  end
end