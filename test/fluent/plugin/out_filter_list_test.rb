require 'test_helper'

class Fluent::OutFilterListTest < Minitest::Test
  CONFIG = %[
  ]

  CONFIG_1 = %[
    key_to_filter x
    patterns_file_path test/fluent/plugin/patterns.txt
  ]

  CONFIG_2 = %[
    key_to_filter x
    patterns_file_path test/fluent/plugin/patterns.txt
    tag_when_filtered t2
  ]

  def setup
    Fluent::Test.setup
  end

  def create_driver(conf = CONFIG, tag = 'test')
    Fluent::Test::OutputTestDriver.new(Fluent::FilterListOutput, tag).configure(conf)
  end

  def test_that_it_has_a_version_number
    refute_nil Fluent::Plugin::OutFilterList::VERSION
  end

  def test_it_does_something_useful
    assert true
  end

  def test_hoge
    assert 1 == 1
  end

  def test_message_including_pattern_should_be_filtered
    d = create_driver(CONFIG_1)
    assert_equal "x", d.instance.key_to_filter
    assert_equal "", d.instance.tag_when_filtered
    d.run {
      d.emit({ "a" => 1, "b" => 2, "x" => "ab"})
      d.emit({ "a" => 1, "b" => 2, "x" => "abc"})
      d.emit({ "a" => 1, "b" => 2, "x" => "xabcdef"})
    }
    emits = d.emits
    assert_equal 1, emits.length
  end

  def test_matching_record_should_be_retagged_when_configured_to_do_so
    d = create_driver(CONFIG_2, "t1")
    assert_equal "x", d.instance.key_to_filter
    assert_equal "t2", d.instance.tag_when_filtered
    d.run {
      d.emit({ "a" => 1, "b" => 2, "x" => "ab"})
      d.emit({ "a" => 1, "b" => 2, "x" => "xabcdef"})
    }
    emits = d.emits
    assert_equal 2, emits.length
    assert_equal "t1", emits[0][0] # tag
    assert_equal "t2", emits[1][0] # tag
  end
end
