# frozen_string_literal: true

module HashZen
  class Diff
    def initialize(base:, target:, **opts)
      @base, @target, @opts = Utils.symbolize(base), Utils.symbolize(target), opts
      @result = {}
      process
    end

    def result
      @result
    end

    # Given array of keys return missing, extra, common.
    # input is compared to the reference
    def keys_diff(keys_input, keys_reference)
      {
        missing: keys_reference - keys_input,
        extra: keys_input - keys_reference,
        common: keys_input & keys_reference
      }
    end

    # Deep dive on the key
    def key_diff(key)
      k1, k2 = @base[key].keys, @target[key].keys
      rv = keys_diff(k1, k2)

      rv[:diff] = rv[:common].map{|sub_key|
        s_diff = if @base[key][sub_key] == @target[key][sub_key]
          nil
        else
          "#{@base[key][sub_key]} (#{@target[key][sub_key]})"
        end
        s_diff ? "#{sub_key} : #{s_diff}" : nil
      }.compact.join(", ")
    end

    def process
      @result.merge!(keys_diff(@base.keys, @target.keys))
    end
  end
end
