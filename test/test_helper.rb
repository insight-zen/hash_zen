# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "hash_zen"


# require "minitest/focus"
# require "minitest/pride"
require "minitest/reporters"
# require "minitest/mock"
# require "minitest/autorun"

Minitest::Reporters.use!(Minitest::Reporters::ProgressReporter.new, ENV, Minitest.backtrace_filter)

