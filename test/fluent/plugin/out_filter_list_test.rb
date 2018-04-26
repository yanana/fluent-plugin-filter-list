# frozen_string_literal: true

require 'test_helper'
require 'fluent/test/driver/output'

module Fluent
  module Plugin
    class OutFilterListTest < Minitest::Test
      CONFIG = %(
      )

      CONFIG_1 = %(
        key_to_filter x
        patterns_file_path test/fluent/plugin/patterns.txt
        <retag>
          tag t2
        </retag>
        <retag_filtered>
          add_prefix x
        </retag_filtered>
      )

      CONFIG_2 = %(
        key_to_filter x
        patterns_file_path test/fluent/plugin/patterns.txt
        <retag>
          tag t2
        </retag>
      )

      CONFIG_3 = %(
        key_to_filter abc
        patterns_file_path test/fluent/plugin/patterns.txt
        <retag>
          tag t
          add_prefix x
        </retag>
      )

      CONFIG_4 = %(
        key_to_filter abc
        patterns_file_path test/fluent/plugin/patterns.txt
        <retag_filtered>
          tag t
          add_prefix x
        </retag_filtered>
      )

      CONFIG_5 = %(
        key_to_filter foo
        patterns_file_path test/fluent/plugin/patterns.txt
        filter_empty true
        <retag>
          tag bar
        </retag>
        <retag_filtered>
          tag buzz
        </retag_filtered>
      )

      def setup
        Fluent::Test.setup
      end

      def create_driver(conf = CONFIG)
        Fluent::Test::Driver::Output.new(Fluent::Plugin::FilterListOutput).configure(conf)
      end

      def test_that_it_has_a_version_number
        refute_nil Fluent::Plugin::FilterList::VERSION
      end

      def test_that_tag_and_add_prefix_cannot_be_set_simultaneously_for_retag_section
        assert_raises Fluent::ConfigError do
          create_driver(CONFIG_3)
        end
      end

      def test_that_tag_and_add_prefix_cannot_be_set_simultaneously_for_retag_filtered_section
        assert_raises Fluent::ConfigError do
          create_driver(CONFIG_4)
        end
      end

      def test_retag_filtered_config_with_add_prefix
        d = create_driver(CONFIG_1)
        assert_equal "x", d.instance.key_to_filter
        assert_equal "t2", d.instance.retag.tag
        assert_nil d.instance.retag_for_filtered.tag
        assert_equal "x", d.instance.retag_for_filtered.add_prefix
      end

      def test_config_without_retag_filtered
        d = create_driver(CONFIG_2)
        assert_equal "x", d.instance.key_to_filter
        assert_equal "t2", d.instance.retag.tag
        assert_nil d.instance.retag_for_filtered
      end

      def test_matching_record_should_be_retagged_when_configured_to_do_so
        d = create_driver(CONFIG_1)
        d.run(default_tag: "t1") do
          d.feed("a" => 1, "b" => 2, "x" => "ab")
          d.feed("a" => 1, "b" => 2, "x" => "abc")
          d.feed("a" => 1, "b" => 2, "x" => "xabcdef")
        end
        events = d.events
        assert_equal 3, events.length
        assert_equal(%w[t2 x.t1 x.t1], events.map { |e| e[0] }) # tag
      end

      def test_message_including_pattern_should_be_filtered_when_no_retag_filtered_section
        d = create_driver(CONFIG_2)
        d.run(default_tag: "t1") do
          d.feed("a" => 1, "b" => 2, "x" => "ab")
          d.feed("a" => 1, "b" => 2, "x" => "xabcdef")
        end
        events = d.events
        assert_equal 1, events.length
        assert_equal "t2", events[0][0] # tag
      end

      def test_empty_message_matches_when_filter_empty_is_true
        d = create_driver(CONFIG_5)
        d.run(default_tag: 't1') do
          d.feed('a' => 1, 'b' => 2, 'foo' => '  ')
          d.feed('a' => 1, 'b' => 2, 'foo' => '')
        end
        events = d.events
        assert_equal 2, events.length
        assert_equal(%w[buzz buzz], events.map { |e| e[0] }) # tag
      end
    end
  end
end
