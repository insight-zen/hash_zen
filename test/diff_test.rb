# frozen_string_literal: true

require "test_helper"

module HashZen
  class DiffTest < Minitest::Test
    # def test_basics
    #   h1 = {
    #     entity_id: { type: :integer, numeric_precision: 32 },
    #     updated_at: { bar: "baaz", type: :datetime, limit: 12, null: false },
    #   }

    #   h2 = {
    #     user_id: { type: :integer, numeric_precision: 32 },
    #     updated_at: { foo: "bar", type: :datetime, limit: 6, null: true },
    #   }

    #   d = Diff.new(base: h1, target: h2)
    #   assert_equal({ missing: [:user_id], extra: [:entity_id], common: [:updated_at] }, d.result)

    #   d = Diff.new(base: h2, target: h1)
    #   assert_equal({ extra: [:user_id], missing: [:entity_id], common: [:updated_at] }, d.result)

    #   d = Diff.new(base: h1, target: h2)
    #   assert_equal("limit : 12 (6), null : false (true)", d.key_diff(:updated_at))
    # end

    # [
    #   { h1: { a: 1 }, h2: { a: 1   }, result: { },   desc: "identical" },
    #   { h1: { a: 1 }, h2: { a: "1" }, result: { type: :class, values: ["Integer", "String"] },   desc: "value class is different" },
    #   { h1: { a: 1 }, h2: { a: 2   }, result: { type: :value, values: [1, 2] },                  desc: "value is different" },
    #   { h1: { a: 1 }, h2: { a: nil }, result: { type: :class, values: ["Integer", "NilClass"] }, desc: "target value is nil" },
    # ].each_with_index do |spec, ix|
    #   test "diff #{ ix }" do
    #     msg = %Q!#{spec[:desc] ? "Asking for #{spec[:desc]}\n" : ''}With spec: #{ spec }!
    #     assert_equal spec[:result], Diff.new(base: spec[:h1], target: spec[:h2]).delta(key: :a), msg
    #   end
    # end

    # test "deltas" do
    #   spec = { h1: { z: 99, a: 1, b: "101", c: { p: 1 } }, h2: { z: 99, a: 2, b: 101, c: { p: 2 } } }
    #   rv = Diff.new(base: spec[:h1], target: spec[:h2]).deltas
    #   assert_equal true, Utils.include?(input: rv, keys: [:common_deltas]), rv
    #   assert_equal true, Utils.include?(input: rv[:common_deltas], keys: [:a, :b, :c]), rv
    # end

    test "nulls are ignored" do
      h1 = { column_name: "group", type: :string,  limit: 100, index: :yes, x1: nil }
      h2 = { column_name: "group", type: :integer, limit: 55, null: false, y1: nil }
      hd = Diff.new(base: h1, target: h2)
      expected = { missing: [:null], extra: [:index] }
      assert_hash_contained(expected: expected, actual: hd.result[:groups])

      hd = Diff.new(base: h1, target: h2, keep_nils: true)
      expected = { missing: [:null, :y1], extra: [:index, :x1] }
      assert_hash_contained(expected: expected, actual: hd.result[:groups])
    end

    [
      { v1: 1,   v2: 1,   result: :identical },
      { v1: 1,   v2: "1", result: :delta, desc: "Class is different" },
      { v1: 1,   v2: 2,   result: :delta, desc: "Value is different" },
      { v1: nil, v2: 2,   result: :delta, desc: "v1 nil" },
      { v1: 1,   v2: nil,   result: :delta, desc: "v2 nil" },
    ].each_with_index do |spec, ix|
      test "comp_values #{ ix }" do
        msg = %Q!#{spec[:desc] ? "Asking for #{spec[:desc]}\n" : ''}With spec: #{ spec }!
        hd = Diff.new(base: {}, target: {})
        assert_nil_equal spec[:result], hd.comp_values(v1: spec[:v1], v2: spec[:v2]), msg
      end
    end

    test "boolean" do
      h1 = { column_name: "group", type: :string,  limit: 100, index: :yes, x1: nil, h1: { a: 1, b: "foo" } }
      h2 = { column_name: "group", type: :integer, limit: 55, null: false, y1: nil, h1: { a: 2, b: "foo" } }
      hd = Diff.new(base: h1, target: h2)
      assert_equal false, hd.boolean

      hd = Diff.new(base: h1, target: h1)
      assert_equal true, hd.boolean

      hd = Diff.new(base: h2, target: h2)
      assert_equal true, hd.boolean
    end

    test "one line result" do
      h1 = { column_name: "group", type: :string,  limit: 100, index: :yes, x1: nil, h1: { a: 1, b: "foo" } }
      h2 = { column_name: "group", type: :integer, limit: 55, null: false, y1: nil, h1: { a: 2, b: "foo" } }
      hd = Diff.new(base: h1, target: h2)
      assert_equal "Missing: [null], Extra: [index], Deltas: [h1, limit, type]", hd.result_one_line

      hd = Diff.new(base: h2, target: h1)
      assert_equal "Missing: [index], Extra: [null], Deltas: [h1, limit, type]", hd.result_one_line
    end

    test "key map" do
      h1 = { column_name: "group", type: :string,  limit: 100, index: :yes, x1: nil, h1: { a: 1, b: "foo" } }
      h2 = { column_name: "group", type: :integer, limit: 55, null: false, y1: nil, h1: { a: 2, b: "foo" } }
      hd = Diff.new(base: h1, target: h2)
      result = {
        null: { s: :missing, v: [nil, false] },
        index: { s: :extra, v: [:yes, nil] },
        column_name: { s: :identical, v: ["group", "group"] },
        type: { s: :delta, v: [:string, :integer] },
        limit: { s: :delta, v: [100, 55] },
        h1: { s: :delta, v: [{ a: 1, b: "foo" }, { a: 2, b: "foo" }] }
      }
      rv = hd.result[:map]
      assert_hash_equal(expected: result, actual: rv)
    end

    [
      { result: true, desc: "Neither only nor except is speciifed" },

      { only: :a,         result: true },
      { only: :a,         check: :c, result: false },
      { except: :a,       result: false },
      { except: :a,       check: :c, result: true },

      { only: [:a, :b],   result: true },
      { except: [:a, :b], result: false },
      { only: [:a, :b],   check: :c, result: false },
      { except: [:a, :b], check: :c, result: true },

      { only: :a, except: :a, result: false },
      { only: :a, except: :b, result: true },
      { only: :a, except: :a, check: :c, result: false },
      { only: :a, except: :b, check: :c, result: false },
      { only: [:a, :c], except: :b, check: :c, result: true },
    ].each_with_index do |spec, ix|
      test "only_except #{ ix }" do
        spec[:check] ||= :a
        msg = %Q!#{spec[:desc] ? "Asking for #{spec[:desc]}\n" : ''}With spec: #{ spec }!
        hd = Diff.new(base: {}, target: {})
        assert_nil_equal spec[:result], hd.only_except?(only: spec[:only], except: spec[:except], check: spec[:check]), msg
      end
    end

    [
      { key: :null,        result: " -+ null: (missing) false (FalseClass)", desc: "s: missing" },
      { key: :index,       result: " +- index: (extra) yes (Symbol)", desc: "s: extra" },
      { key: :column_name, result: " == column_name: (identical) ", desc: "s: identical" },
      { key: :limit,       result: " <> limit: (delta) 100 != 55", desc: "s: delta" },
    ].each_with_index do |spec, ix|
      test "value_str #{ ix }" do
        spec[:opts] ||= {}
        h1 = { column_name: "group", type: :string,  limit: 100, index: :yes, x1: nil, h1: { a: 1, b: "foo" } }
        h2 = { column_name: "group", type: :integer, limit: 55, null: false, y1: nil, h1: { a: 2, b: "foo" } }
        msg = %Q!#{spec[:desc] ? "Asking for #{spec[:desc]}\n" : ''}With spec: #{ spec }!
        hd = Diff.new(base: h1, target: h2)
        assert_equal true, hd.result[:map].key?(spec[:key]), "Available keys in results map: #{hd.result[:map].keys.join(', ')}"
        assert_nil_equal spec[:result], hd.value_str(key: spec[:key], result: hd.result[:map][spec[:key]], **spec[:opts]).gsub(/\s+/, " "), msg
      end
    end


    test "formats and result options" do
      h1 = { column_name: "group", type: :string,  limit: 100, index: :yes, x1: nil, h1: { a: 1, b: "foo" } }
      h2 = { column_name: "group", type: :integer, limit: 55, null: false, y1: nil, h1: { a: 2, b: "foo" } }
      hd = Diff.new(base: h1, target: h2)
      assert_match(/^Missing/, hd.result_one_line_detailed)
      assert_match(/Hash Delta Follows/,  hd.result_itemized(except: :identical, format: :string))
    end
  end
end
