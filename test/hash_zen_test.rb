# frozen_string_literal: true

require "test_helper"

class TestHashZen < Minitest::Test
  test "one two three" do
    assert_equal 2, 2
  end

  def test_that_it_has_a_version_number
    refute_nil ::HashZen::VERSION
  end
end
