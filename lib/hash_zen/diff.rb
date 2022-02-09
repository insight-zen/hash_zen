# frozen_string_literal: true

module HashZen
  class Diff
    # Compares BASE with TARGET
    # Tries to emulate diff by showcasing missing, extra and delta
    #
    def initialize(base:, target:, **opts)
      @base, @target, @opts, @result = Utils.symbolize(base), Utils.symbolize(target), opts, {}
      unless opts[:keep_nils]
        @base.compact!
        @target.compact!
      end
      build_key_groups
      build_key_map
    end

    attr_reader :result

    # Only look at the keys and categorize them based on where they appear
    # missing: Present in target but not in base
    # extra:   Present in base but not in target
    # common:  Present in both
    # -- Added by build_key_map: common = identical + delta
    #  identical: values are identical
    #  delta: values are not identical
    def build_key_groups
      base_keys, target_keys = @base.keys, @target.keys
      rv = {
        missing: target_keys - base_keys,
        extra: base_keys - target_keys,
        common: base_keys & target_keys
      }
      @result[:groups] = rv
      rv
    end

    def comp_values(v1:, v2:, **opts)
      v1.class == v2.class && v1 == v2 ? :identical : :delta
    end

    # For every key, set status, values
    # Adds identical and delta to @result[:groups] to subdivide common group
    def build_key_map
      rv = {}
      result[:groups][:missing].each { |k| rv[k] = { s: :missing, v: [nil, @target[k]] } }
      result[:groups][:extra].each { |k| rv[k] = { s: :extra, v: [@base[k], nil] } }
      result[:groups][:common].each { |k|
        rv[k] = {
          s: comp_values(v1: @base[k], v2: @target[k]),
          v: [
            @base[k].is_a?(Hash) ? @base[k].compact : @base[k],
            @target[k].is_a?(Hash) ? @target[k].compact : @target[k]
            ]
        }
      }
      @result[:map] = rv
      @result[:groups][:identical] = rv.reduce([]) { |acc, (k, v)| acc.push(k) if v[:s] == :identical; acc }
      @result[:groups][:delta] = rv.reduce([]) { |acc, (k, v)| acc.push(k) if v[:s] == :delta; acc }
    end

    [:missing, :extra, :common, :identical, :delta].each do |k|
      define_method "has_#{k}?" do
        @result[:groups][k].length > 0 ? true : false
      end

      define_method "#{k}_keys" do
        @result[:groups][k]
      end
    end

    # True/False answer to the question - Are the two hashes identical
    def boolean
      [:missing, :extra, :delta].map { |k| @result[:groups][k] }.flatten.compact.length > 0 ? false : true
    end

    def result_one_line
      return "Identical" if boolean
      [
        result[:groups][:missing].empty? ? nil : "Missing: [%s]" % result[:groups][:missing].sort.join(", "),
        result[:groups][:extra].empty? ?  nil : "Extra: [%s]" % result[:groups][:extra].sort.join(", "),
        result[:groups][:delta].empty? ?  nil : "Deltas: [%s]" % result[:groups][:delta].sort.join(", "),
      ].compact.join(", ")
    end

    def result_one_line_detailed
      [
        result[:groups][:missing].empty? ? nil : "Missing: [%s]" % result[:groups][:missing].sort.join(", "),
        result[:groups][:extra].empty? ?  nil : "Extra: [%s]" % result[:groups][:extra].sort.join(", "),
        result[:groups][:delta].empty? ?  nil : result[:groups][:delta].map { |k| result_line(key: k) }.join(", "),
      ].flatten.compact.join(", ")
    end

    # Code for status on the result display
    def status_sym(s)
      case s
      when :missing
        "-+"
      when :extra
        "+-"
      when :identical
        "=="
      when :delta
        "<>"
      end
    end

    def result_line(key:, **opts)
      value_str(key: key, result: result[:map][key], **opts)
    end

    # If key appears in a map, give a Diff for the values saved
    def key_diff(key:, **opts)
    end

    # Given one item (key, value) of the result[:map] hash, formats for display
    def value_str(key:, result:, **opts)
      code, v0, v1 = result[:s], result[:v][0], result[:v][1]
      exp_str = if code == :extra
        "%s (%s)" % [v0, v0.class]
      elsif code == :missing
        "%s (%s)" % [v1, v1.class]
      elsif code == :delta
        if v0.is_a?(Hash)
          hd = Diff.new(base: v0, target: v1)
          %Q! ---\n#{hd.result_itemized(except: :identical, indent: 4, compact: true).join("\n")}!
          # hd.result_one_line_detailed
        else
          "%s != %s" % [v0, v1 ]
        end
      elsif code == :identical
        ""
      else
        result.to_s
      end
      indent = " " * (opts[:indent] || 1)
      return("%s%02s %s %s" % [ indent, status_sym(code), "#{key}:", exp_str]) if opts[:compact]
      "%s%02s %-16s %-10s %s" % [ indent, status_sym(code), "#{key}:", "(#{code})", exp_str]
    end

    # To select from a list of keys using only: and except: specifications.
    # See tests for examples
    def only_except?(only: nil, except: nil, check:)
      if only
        [only].flatten.include?(check) &&
        (except.nil? || ![except].flatten.include?(check))
      elsif except
        ![except].flatten.include?(check) &&
        (only.nil? || [only].flatten.include?(check))
      else
        true
      end
    end

    def result_itemized(**opts)
      rv = result[:map].filter_map { |(column_name, result)|
        # res = only_except?(only: opts[:only], except: opts[:except], check: result[:s])
        only_except?(only: opts[:only], except: opts[:except], check: result[:s]) ? result_line(key: column_name, **opts) : nil
      }
      puts rv.join("\n") if opts[:log]
      rv = rv.join("\n") if opts[:format] == :string
      opts[:log] ? nil : rv
    end

    # provide the results for the operation
    def format(**opts)
    end

    # # If a key exists in both hashes, provides details of the differences
    # # If the value of either key is a hash, will run deltas on the hashes
    # # return value is a hash { type: diff_type, values: [base_value, target_value] }
    # def delta(key:, **opts)
    #   raise("Key: #{key} does not exist in both hashes.\n#{keys_diff}") unless @result[:common].include?(key)
    #   return Diff.new(base: @base[key], target: @target[key]).deltas if @base[key].is_a?(Hash) || @target[key].is_a?(Hash)
    #   rv = {}
    #   if @base[key].class != @target[key].class
    #     rv.merge!(type: :class, values: [@base[key].class.to_s, @target[key].class.to_s])
    #   elsif @base[key] != @target[key]
    #     # { type: :value, msg: "Base: #{@base[key]}, Target: #{@target[key]}" }
    #     { type: :value, values: [@base[key], @target[key]] }
    #   else
    #     {}
    #   end
    #   rv
    # end

    # # Delta for all keys
    # def common_key_deltas()
    #   @result[:common].filter_map { |k|
    #     rv = delta(key: k)
    #     rv.length > 0 ? [k, rv] : nil
    #   }.to_h
    # end

    # # Returns the difference
    # def deltas(**opts)
    #   input, reference = @base.keys, @target.keys
    #   rv = {
    #     missing: reference - input,
    #     extra: input - reference,
    #     common_deltas: common_key_deltas
    #   }
    #   rv.keys.each { |k| rv.delete(k) if rv[k].length == 0 }
    #   rv
    # end

    # # Deep dive on the key
    # def key_diff(key)
    #   k1, k2 = @base[key].keys, @target[key].keys
    #   rv = keys_diff(input: k1, reference: k2)

    #   rv[:diff] = rv[:common].filter_map { |sub_key|
    #     s_diff = if @base[key][sub_key] == @target[key][sub_key]
    #       nil
    #     else
    #       "#{@base[key][sub_key]} (#{@target[key][sub_key]})"
    #     end
    #     s_diff ? "#{sub_key} : #{s_diff}" : nil
    #   }.join(", ")
    # end
  end
end
