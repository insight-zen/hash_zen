# frozen_string_literal: true

module HashZen
  class Merge
    class << self
      def compact(input:, **opts)
        input.compact.tap do |h|
          h[:class] = h[:class].flatten.compact.join(" ") if h[:class]
          h[:style] = h[:style].flatten.compact.join(";") if h[:style]
          [:class, :style].each { |k| h.delete(k) if Utils.blank?(h[k]) }
        end
      end

      # HTML style merging
      #  class: combines and append join in the end
      #  data:  combines in to a hash
      #  style: concatenation
      def html(base:, mix:, **opts)
        return Utils.symbolize(base || {}) if mix.nil? || mix.length == 0

        rv = Utils.symbolize(mix || {}).reduce(Utils.symbolize(base)) { |acc, (key, value)|
          if [:class].include?(key)
            acc[key] = [acc[key], value].flatten.compact
          elsif [:style].include?(key)
            acc[key] = [acc[key], value]
          elsif [:data].include?(key) || value.is_a?(Hash)
            raise("Cannot mix key: #{key} with a hash value #{value} into base value #{acc[key]} which is a #{acc[key].class.name}}") unless acc[key].nil? || acc[key].is_a?(Hash)
            acc[key] = html(base: acc[key] || {}, mix: value)
          else
            acc[key] = value
          end
          acc
        }
        rv[:style] = rv[:style].flatten.compact.map { |e| e.to_s.delete_suffix(";") }.join("; ") + ";" if rv.key?(:style)
        Utils.hash_compact(input: rv)
      end
    end
  end
end
