# frozen_string_literal: true

module HashZen
  class Utils
    class << self
      def transform(original:, **opts, &block)
        original.inject({}) { |result, (key, value)|
          value = (options[:deep] && Hash === value) ? transform(value, **opts, &block) : value
          block.call(result, key, value)
          result
        }
      end

      # Deep symbolize incoming hash. If input is nil, returns blank hash
      def symbolize(input)
        return {} unless input
        input.map { |key, value|
          [ key.to_s.to_sym, value.is_a?(Hash) ? symbolize(value) : value ]
        }.to_h
      end

      # Returns true/false after checking if all keys exists in input.
      # The type of check is controlled by opts[:check]
      #  all:   (default) All keys must be present in input
      #  any:   At least one key must be present in input
      #  exact: All + no additional keys should be present in input
      #
      def include?(input:, keys:, **opts)
        return false unless input.is_a?(Hash)
        input_keys, check_keys = input.keys, [keys].flatten.uniq
        missing_keys = check_keys - input_keys
        extra_keys = input_keys - check_keys

        case opts[:check]
        when :any
          check_keys.length > missing_keys.length ? true : false
        when :exact
          extra_keys.length == 0 && missing_keys.length == 0 ? true : false
        else # when :all
          missing_keys.length == 0 ? true : false
        end
      end
    end
  end
end
