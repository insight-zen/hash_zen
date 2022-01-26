# frozen_string_literal: true

module HashZen
  module HashTestHelper
    # Testing helper for hash comparisons

    # Check that has INPUT has KEYS.
    # INPUT can have other keys, this test only checks that all KEYS are present in INPUT
    def assert_hash_has_keys(input:, keys:, **opts)
      exp_keys, actual_keys = keys, input.keys
      missing_keys = actual_keys - exp_keys
      msg = "Checking that keys: [#{keys.sort.join(', ')}] are present in [#{input.keys.sort.join(', ')}]\n. Missing keys: [#{missing_keys.join(', ')}]"
      assert_equal true, HashZen::Utils.include?(input: input, keys: keys), msg
    end

    # Checks that EXPECTED hash is contained in the ACTUAL Hash
    # First checks that keys of expected are in actual,
    # Then for each key checks that class and value of the key in the actual hash
    def assert_hash_contained(expected:, actual:, **opts)
      assert_hash_has_keys(input: actual, keys: expected.keys)
      expected.each_pair do |key, value|
        msg = "#{opts[:msg]}\nChecking class for key: #{key}"
        assert_equal value.class.to_s, actual[key].class.to_s, msg

        msg = "#{opts[:msg]}\nChecking value for key: #{key}"
        assert_equal value, actual[key], msg
      end
    end

    # Checks that all keys of expected are present in actual
    # Then for each key checks that class and value of the key in the actual hash
    def assert_hash_equal(expected:, actual:, **opts)
      msg = "Checking that actual: #{actual} is equal to expected: #{expected}"

      if expected == actual
        assert_equal expected, actual, msg
      else
        assert_equal [], (expected.keys - actual.keys), "Checking keys equality. Expected keys: #{expected.keys}, Actual Keys: #{actual.keys}, delta: #{expected.keys - actual.keys}"
        assert_equal [], (actual.keys - expected.keys), "Checking keys equality. Expected keys: #{expected.keys}, Actual Keys: #{actual.keys}, delta: #{actual.keys - expected.keys}"
        expected.each_pair do |key, value|
          msg = "Checking class for key: #{key}"
          assert_equal value.class.to_s, actual[key].class.to_s, msg

          msg = "Checking value for key: #{key}"
          assert_equal value, actual[key], msg
        end
      end
    end
  end
end
