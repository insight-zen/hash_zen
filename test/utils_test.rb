# frozen_string_literal: true

require "test_helper"

module HashZen
  class UtilsTest < Minitest::Test

    [
      { input: nil,  result: {} },
      { input: {}, result: {} },
      { input: { a: "X", b: 2 },        result: { a: "X", b: 2 }},
      { input: { "a" => "X", :b => 2 }, result: { a: "X", b: 2 }},
      { input: { "a" => 1, :b => 2, 3 => :foo }, result: { a: 1, b: 2, :"3" => :foo }},

      { input:  { "a" => "X", "b" => {"p" => 11, "q" => { "r" => 200 } } },
        result: { a: "X", b: { p: 11, q: { r: 200 }} }
      },

    ].each_with_index do |spec, ix|
      define_method "test_name_#{ ix }" do
        msg = "With spec: #{ spec }"
        assert_equal spec[:result], Utils.symbolize(spec[:input]), msg
      end
    end

  end
end