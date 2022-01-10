directories %w(lib test)

guard :minitest,  all_on_start: false do
  watch(%r{^test/(.+)_test\.rb$})
  watch(%r{^lib/hash_zen/(.+)\.rb$})         { |m| "test/#{m[1]}_test.rb" }
end