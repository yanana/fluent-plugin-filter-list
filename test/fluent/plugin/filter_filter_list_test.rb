require 'test_helper'
require 'fluent/test/driver/filter'

module Fluent
  module Plugin
    class FilterFilterListTest < Minitest::Test
      EMPTY_CONFIG = %(
      )

      CONFIG1 = %(
        filter AC
        key_to_filter x
        patterns_file_path test/fluent/plugin/patterns.txt
      )
      CONFIG2 = %(
        filter IP
        key_to_filter ip
        patterns_file_path test/fluent/plugin/ip.txt
      )

      def setup
        Fluent::Test.setup
      end

      def create_driver(conf = EMPTY_CONFIG)
        Fluent::Test::Driver::Filter.new(Fluent::Plugin::FilterListFilter).configure(conf)
      end

      def filter(config, msg, time = event_time("2017-07-12 19:20:21 UTC"))
        d = create_driver(config)
        d.run { d.feed('test', time, msg) }
        d.filtered_records
      end

      def test_that_empty_config_results_in_pass_through_filter
        es = filter('', { 'x' => 'foo', 'y' => 'bar' })
        assert_equal 1, es.size
      end

      def test_that_message_whose_filtered_key_value_is_nil_should_be_ignored
        es = filter(CONFIG1, { 'x' => nil, 'y' => 'foo' })
        assert_equal 1, es.size
      end

      def test_that_message_containing_a_pattern_is_filtered
        d = create_driver(CONFIG1)
        d.run(default_tag: 'test') do
          d.feed('x' => 'ab', 'y' => 'foo')
          d.feed('x' => 'abc', 'y' => 'foo')
          d.feed('x' => 'abcd', 'y' => 'foo')
          d.feed('x' => 'zabcd', 'y' => 'foo')
        end
        es = d.filtered_records
        assert_equal 1, es.length
        assert_equal 'ab', es[0]['x']
        assert_equal 'foo', es[0]['y']
      end

      def test_that_message_containing_an_ip_is_filtered
        d = create_driver(CONFIG2)
        d.run(default_tag: 'test') do
          d.feed('ip' => '192.168.1.1', 'y' => 'foo')
          d.feed('ip' => '192.168.1.255', 'y' => 'foo')
          d.feed('ip' => '192.168.2.0', 'y' => 'foo')
          d.feed('ip' => '127.0.0.1', 'y' => 'foo')
        end
        es = d.filtered_records
        assert_equal 2, es.length
        assert_equal '192.168.2.0', es[0]['ip']
        assert_equal 'foo', es[0]['y']
        assert_equal '127.0.0.1', es[1]['ip']
        assert_equal 'foo', es[1]['y']
      end
    end
  end
end
