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
  end
end
