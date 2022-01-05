# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/query_filter"

module ShopifyCLI
  module Theme
    class QueryFilterTest < Minitest::Test
      def test_match_when_pattern_is_nil
        assert QueryFilter.new.match?("../file.txt")
      end

      def test_match_when_pattern_is_empty
        assert QueryFilter.new("").match?("../file.txt")
      end

      def test_match_when_pattern_is_a_regex_and_matches
        filter = QueryFilter.new("templates/")
        assert filter.match?("templates/test.txt")
      end

      def test_match_when_pattern_is_a_regex_and_does_not_match
        filter = QueryFilter.new("build/")
        refute filter.match?("templates/test.txt")
      end

      def test_match_when_pattern_is_a_glob_and_matches
        filter = QueryFilter.new("/\\.txt/")
        assert filter.match?("templates/test.txt")
      end

      def test_match_when_pattern_is_a_glob_and_does_not_match
        filter = QueryFilter.new("/\\.liquid/")
        refute filter.match?("templates/test.txt")
      end
    end
  end
end
