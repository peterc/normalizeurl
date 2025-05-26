# frozen_string_literal: true

require "test_helper"

class TestCsvCases < Minitest::Test
  def setup
    @csv_file = File.join(__dir__, "url_test_cases.csv")
  end

  def test_csv_cases
    skip "CSV test file not found" unless File.exist?(@csv_file)

    CSV.foreach(@csv_file, headers: true) do |row|
      source_url = row['source_url']
      expected_url = row['expected_url']
      description = row['description'] || "#{source_url} -> #{expected_url}"

      next if source_url.nil? || source_url.strip.empty?
      next if expected_url.nil? || expected_url.strip.empty?

      actual = Normalizeurl.normalize(source_url.strip)
      assert_equal expected_url.strip, actual, "Failed: #{description}"
    end
  end
end
