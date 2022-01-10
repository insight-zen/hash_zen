# frozen_string_literal: true

require "test_helper"

module HashZen
  class DiffTest < Minitest::Test

    def test_basics
      h1 = {
        entity_id: { type: :integer, numeric_precision: 32 },
        updated_at: { bar: "baaz", type: :datetime, limit: 12, null: false },
      }

      h2 = {
        user_id: { type: :integer, numeric_precision: 32 },
        updated_at: { foo: "bar", type: :datetime, limit: 6, null: true },
      }

      d = Diff.new(base: h1, target: h2)
      assert_equal({missing: [:user_id], extra: [:entity_id], common: [:updated_at]}, d.result)

      d = Diff.new(base: h2, target: h1)
      assert_equal({extra: [:user_id], missing: [:entity_id], common: [:updated_at]}, d.result)

      d = Diff.new(base: h1, target: h2)
      assert_equal("limit : 12 (6), null : false (true)", d.key_diff(:updated_at))
    end


  end
end