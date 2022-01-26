# frozen_string_literal: true

require "test_helper"

module HashZen
  class UtilsTest < Minitest::Test
    [
      { input: nil,  result: {} },
      { input: {}, result: {} },
      { input: { a: "X", b: 2 },        result: { a: "X", b: 2 } },
      { input: { "a" => "X", :b => 2 }, result: { a: "X", b: 2 } },
      { input: { "a" => 1, :b => 2, 3 => :foo }, result: { a: 1, b: 2, "3": :foo } },

      { input:  { "a" => "X", "b" => { "p" => 11, "q" => { "r" => 200 } } },
        result: { a: "X", b: { p: 11, q: { r: 200 } } }
      },
    ].each_with_index do |spec, ix|
      define_method "test_name_#{ ix }" do
        msg = "With spec: #{ spec }"
        assert_equal spec[:result], Utils.symbolize(spec[:input]), msg
      end
    end

    [
      { keys: :a, result: true },
      { keys: :z, result: false },
      { keys: :a, result: true, check: :all, desc: "with explicit check flag of :all" },
      { keys: :z, result: false, check: :all, desc: "with explicit check flag of :all" },

      { keys: [:a, :b, "a"], result: true, desc: "multiple_keys" },
      { keys: [:a, :c, "a"], result: false, desc: "multiple_keys" },

      { keys: :x,            result: false, check: :any },
      { keys: [:x, :y],      result: false, check: :any },
      { keys: :a,            result: true, check: :any },
      { keys: [:a],          result: true, check: :any },
      { keys: [:a, "a"],     result: true, check: :any },
      { keys: [:a, "a", :b], result: true, check: :any },
      { keys: [:a, "a", :c], result: true, check: :any },

      { keys: [:a],          result: false, check: :exact },
      { keys: [:a, "a", :x], result: false, check: :exact },
      { keys: [:a, "a", :b], result: true, check: :exact },

    ].each_with_index do |spec, ix|
      test "includes #{ ix }" do
        spec[:input] = { a: 1, "a" => 2, b: 3 } unless spec.key?(:input)
        msg = %Q!#{spec[:desc] ? "Asking for #{spec[:desc]}\n" : ''}With spec: #{ spec }!
        assert_nil_equal spec[:result], Utils.include?(input: spec[:input], keys: spec[:keys], check: spec[:check]), msg
      end
    end
  end
end
