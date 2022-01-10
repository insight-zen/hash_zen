# frozen_string_literal: true

module HashZen
  class Utils

    class << self
      # Deep symbolize incoming hash. If input is nil, returns blank hash
      def symbolize(input)
        return {} unless input
        input.map { |key, value|
          [ key.to_s.to_sym, value.is_a?(Hash) ? symbolize(value) : value ]
        }.to_h
      end
    end

  end
end