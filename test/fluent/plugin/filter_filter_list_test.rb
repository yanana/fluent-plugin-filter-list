require 'test_helper'

module Fluent
  class FilterFilterListTest < Minitest::Test
    EMPTY_CONFIG = %(
    )

    CONFIG = %(
      key_to_filter x
      patterns_file_path test/fluent/plugin/patterns.txt
    )

    def setup
      Fluent::Test.setup
    end

    def create_driver(conf = EMPTY_CONFIG, tag = 'test')
      Fluent::Test::FilterTestDriver.new(Fluent::FilterListFilter, tag).configure(conf, true)
    end

    def emit(config, msg, time = Time.parse("2017-07-12 19:20:21 UTC").to_i)
      d = create_driver(config)
      d.run { d.emit(msg, time) }.filtered_as_array
    end

    def test_that_empty_config_results_in_pass_through_filter
      es = emit('', { 'x' => 'foo', 'y' => 'bar' })
      assert_equal 1, es.size
    end

    def test_that_message_whose_filtered_key_value_is_nil_should_be_ignored
      es = emit(CONFIG, { 'x' => nil, 'y' => 'foo' })
      assert_equal 1, es.size
    end

    def test_that_message_containing_a_pattern_is_filtered
      d = create_driver(CONFIG)
      es = (
        d.run do
          d.emit('x' => 'ab', 'y' => 'foo')
          d.emit('x' => 'abc', 'y' => 'foo')
          d.emit('x' => 'abcd', 'y' => 'foo')
          d.emit('x' => 'zabcd', 'y' => 'foo')
        end
      ).filtered_as_array.map { |x| x[2] } # extract record
      assert_equal 1, es.length
      assert_equal 'ab', es[0]['x']
      assert_equal 'foo', es[0]['y']
    end
  end
end
