# frozen_string_literal: true

module HashZen
  module AssertiveTestHelper
    def self.included(base)
      base.class_eval do
      end
      base.extend(ClassMethods)
    end

    def assert_nil_equal(expected, actual, message = "")
      if expected.nil?
        assert_nil actual, message
      else
        assert_equal expected, actual, message
      end
    end

    module ClassMethods
      # Rails like dsl to write test
      def test(name, &block)
        test_name = "test_#{name.gsub(/\s+/, '_')}".to_sym
        defined = method_defined? test_name
        raise "#{test_name} is already defined in #{self}" if defined
        if block_given?
          define_method(test_name, &block)
        else
          define_method(test_name) do
            flunk "Provide a block to test in #{name}. That will implement the test."
          end
        end
      end
    end
  end
end
