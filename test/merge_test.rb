# frozen_string_literal: true

require "test_helper"

module HashZen
  class MergeTest < Minitest::Test
    test "combine class style remove blanks" do
      base = { class: :si, id: 123, x: nil, style: "--bg: #f00;" }
      mix = { class: [:foo, :bar], id: 99, y: "", style: "font-size: 12px;" }
      result = { class: [:si, :foo, :bar], id: 99, style: "--bg: #f00; font-size: 12px;" }
      rv = HashZen::Merge.html(base: base, mix: mix)
      assert_nil_equal result, rv
    end

    test "data with ux combo" do
      base = { id: :a1, data: { uxx: { toggle: :a, replace: :c }, code: :foo } }
      mix = { class: [:foor], data: { uxx: { bg: "/rt?1" }, items: 3 } }
      result = { id: :a1, data: { uxx: { toggle: :a, replace: :c, bg: "/rt?1" }, code: :foo, items: 3 }, class: [:foor] }
      rv = HashZen::Merge.html(base: base, mix: mix)
      assert_nil_equal result, rv
    end

    [
      { input: :a,                 result: { code: :a }, desc: "Single input, no overrides" },
      { input: :a, key_name: :div, result: { div: :a }, desc: "key_name specified" },
      { input: :a, key_name: :div, defaults: {div: :foo}, result: { div: :a }, desc: "key_name specified, default key also specified" },
      { input: :a, key_name: :div, defaults: {a: 11, b: "X"}, result: { a: 11, b: "X", div: :a }, desc: "key_name specified, default key also specified" },
    ].each_with_index do |spec, ix|
      test "omni input #{ix}" do
        spec = {key_name: :code, defaults: {}}.merge(spec)
        msg = %Q!With spec: #{spec}\nDesc: #{spec[:desc] ? "" : ""}!
        rv = HashZen::Merge.omni_input(input: spec[:input], key_name: spec[:key_name], defaults: spec[:defaults])
        assert_nil_equal spec[:result], rv, msg
      end
    end

    test "omni input for icon with svg" do
      rv = HashZen::Merge.omni_input(input: :close)
      assert_equal({ code: :close}, rv)

      rv = HashZen::Merge.omni_input(input: { code: :close, class: :foo, style: "padding: 4px" })
      assert_equal({ code: :close, class: [:foo], style: "padding: 4px;" }, rv)

      rv = HashZen::Merge.omni_input(input: { code: :close, data: { a: 9 }, class: :foo, style: "padding: 4px" },
      defaults: {code: :xyz, class: :icon, data: { a: 1, b: 2 }, required: true})
      assert_equal({ code: :close, class: [:icon, :foo], data: { a: 9, b: 2 }, required: true, style: "padding: 4px;" }, rv)
    end
  end
end
