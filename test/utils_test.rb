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

    [
      { input: nil,   result: true, desc: "" },
      { input: false, result: true, desc: "" },
      { input: [],    result: true, desc: "" },
      { input: {},    result: true, desc: "" },
    ].each_with_index do |spec, ix|
      test "blank #{spec[:desc]} #{ ix }" do
        msg = %Q!#{spec[:desc] ? "Asking for #{spec[:desc]}\n" : ''}With spec: #{ spec }!
        assert_nil_equal spec[:result], Utils.blank?(input: spec[:input], **(spec[:opts] || {})), msg
      end
    end

    [
      { input: [:a, 1],               result: [:a, 1], desc: "" },
      { input: [:a, "", nil, "  "],   result: [:a],    desc: "empty string, nil, whitespace string" },
    ].each_with_index do |spec, ix|
      test "array compact #{spec[:desc]} #{ ix }" do
        msg = %Q!#{spec[:desc] ? "Asking for #{spec[:desc]}\n" : ''}With spec: #{ spec }!
        assert_nil_equal spec[:result], Utils.array_compact(input: spec[:input], **(spec[:opts] || {})), msg
      end
    end

    [
      { input: { a: 1, b: nil },         result: { a: 1 },  desc: "" },
      { input: { a: 1, b: "", c: " " }, result: { a: 1 },  desc: "value is empty string and whitespace" },
      { input: { a: [], b: {}, c: 1 }, result: { c: 1 },    desc: "empty array and hash in values" },
    ].each_with_index do |spec, ix|
      test "hash compact #{spec[:desc]} #{ ix }" do
        msg = %Q!#{spec[:desc] ? "Asking for #{spec[:desc]}\n" : ''}With spec: #{ spec }!
        assert_nil_equal spec[:result], Utils.hash_compact(input: spec[:input], **(spec[:opts] || {})), msg
      end
    end

    test "nested hash compact" do
      h = { i: nil, j: "", k: false }
      x = { u: "", v: nil, w: 2, y: [1, nil], z: { f: 1, g: nil } }
      rv = HashZen::Utils.hash_compact(input: { a: 1, b: h, c: x })
      result = { a: 1, c: { w: 2, y: [1], z: { f: 1 } } }
      assert_equal result, rv
    end

    test "nested array compact" do
    end

    [
      { input: { a: 1, b: nil, c: "  ", d: { p: nil, q: "" } },         result: { a: 1 },  desc: "" },
    ].each_with_index do |spec, ix|
      test "generic compact #{spec[:desc]} #{ ix }" do
        msg = %Q!#{spec[:desc] ? "Asking for #{spec[:desc]}\n" : ''}With spec: #{ spec }!
        assert_nil_equal spec[:result], Utils.compact(input: spec[:input], **(spec[:opts] || {})), msg
      end
    end
  end
end
