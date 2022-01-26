# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "hash_zen"

require "minitest/reporters"
require "minitest/autorun"
require "minitest/focus"
require "byebug"

require_relative "./helpers/hash_test_helper"
require_relative "./helpers/assertive_test_helper"

Minitest::Reporters.use!(Minitest::Reporters::ProgressReporter.new, ENV, Minitest.backtrace_filter)

MiniTest::Test.include HashZen::AssertiveTestHelper
MiniTest::Test.include HashZen::HashTestHelper
