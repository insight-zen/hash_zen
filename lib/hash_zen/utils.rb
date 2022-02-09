# frozen_string_literal: true

module HashZen
  class Utils
    class << self
      def nil_false?(input)
        (input.nil? || input == false) ? true : false
      end

      # Input responds to length and length is zero
      def zero_length?(input)
        input.respond_to?(:length) && input.length == 0 ? true : false
      end

      # String that is entirely made up of whitespace
      def blank_string?(input)
        input.is_a?(String) && /\A\s*\z/.match(input) ? true : false
      end

      def blank?(input:, **opts)
        return true if nil_false?(input) || zero_length?(input) || blank_string?(input)
        # Arrays with nil values or Hashes with nil keys
        return true if input.respond_to?(:compact) && input.compact.length == 0
        if input.is_a?(Hash)
          return true if zero_length?(hash_compact(input: input))
        elsif input.is_a?(Array)
          return true if zero_length?(array_compact(input: input))
        end
        false
      end

      # Removes blank keys (nil, false, zero length, white space strings)
      def hash_compact(input:, **opts)
        non_blank_keys = input.filter_map { |k, v| blank?(input: v) ? nil : k }
        input.slice(*non_blank_keys).transform_values { |v| compact(input: v) }
      end

      # Removes blank elements (nil, false, zero length, white space strings)
      def array_compact(input:, **opts)
        input.compact.filter_map { |e| blank?(input: e) ? nil : e }
      end

      def compact(input:, **opts)
        if input.is_a?(Hash)
          hash_compact(input: input, **opts)
        elsif input.is_a?(Array)
          array_compact(input: input, **opts)
        elsif input.respond_to?(:compact)
          input.compact
        else
          input
        end
      end

      # def transform(base:, **opts, &block)
      #   base.inject({}) { |result, (key, value)|
      #     value = (Hash === value) ? transform(baes: value, **opts, &block) : value
      #     block.call(result, key, value)
      #     result
      #   }
      # end

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
