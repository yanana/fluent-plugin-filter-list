# -*- coding: utf-8 -*-

require 'test_helper'
require 'matcher'

class ACMatcherTest < Minitest::Test
  include Matchers

  def test_that_tree_without_leaves_is_built_given_nil_is_passed
    acmatcher = ACMatcher.new(nil)
    assert_equal(acmatcher.trie.root.children, {})
  end

  def test_that_tree_without_leaves_is_built_given_empty_array_is_passed
    acmatcher = ACMatcher.new([])
    assert_equal(acmatcher.trie.root.children, {})
  end

  def test_that_internal_nodes_have_only_one_child_and_leaf_node_has_output_given_singleton_array_is_passed
    acmatcher = ACMatcher.new(['hoge'])
    current_node = acmatcher.trie.root
    while current_node.children.size == 1
      assert(current_node.children.size == 1)
      current_node = current_node.children.values[0]
    end
    assert(current_node.output.include?('hoge'))
  end

  def test_that_output_consists_of_elements_of_input
    kws = %w[hoge bar bar2 abhc]
    acmatcher = ACMatcher.new(kws)

    @outputs = []

    detect_output_of_child = lambda do |node|
      node.children.values.each do |child_node|
        @outputs.push(child_node.output) unless child_node.output.nil?
        detect_output_of_child.call(child_node)
      end
    end

    detect_output_of_child.call(acmatcher.trie.root)
    assert((@outputs - kws).empty?)
  end

  def test_matches_when_a_pattern_is_in_the_middle_of_text
    k1 = 'hoge'
    k2 = 'bar'
    kw = [k1, k2]
    acmatcher = ACMatcher.new(kw)
    assert(acmatcher.matches?("abc#{k1}abc"))
    assert(acmatcher.matches?("abc#{k2}abc"))
    assert(!acmatcher.matches?('abcabc'))
  end

  def test_matches_when_a_pattern_is_at_the_head_of_text
    k1 = 'hoge'
    k2 = 'bar'
    kw = [k1, k2]
    acmatcher = ACMatcher.new(kw)
    assert(acmatcher.matches?(k1 + 'abc'))
    assert(acmatcher.matches?(k2 + 'abc'))
    assert(!acmatcher.matches?('abcabc'))
  end

  def test_matches_when_a_pattern_is_at_the_tail_of_text
    k1 = 'hoge'
    k2 = 'bar'
    kw = [k1, k2]
    acmatcher = ACMatcher.new(kw)
    assert(acmatcher.matches?('abc' + k1))
    assert(acmatcher.matches?('abc' + k2))
    assert(!acmatcher.matches?('abcabc'))
  end

  def test_that_blank_pattern_does_not_match
    acmatcher = ACMatcher.new([''])
    assert(!acmatcher.matches?('foo'))
  end

  def test_nil_pattern_results_to_no_characters_detected
    acmatcher = ACMatcher.new(nil)
    assert(!acmatcher.matches?('foo'))
  end

  def test_nil_text_never_matches
    matcher = ACMatcher.new(['xyz'])
    assert !matcher.matches?(nil)
  end

  def test_blank_text_never_matches
    matcher = ACMatcher.new(['foo'])
    assert(!matcher.matches?(''))
  end

  def test_text_other_than_string_is_converted_to_string_before_comparison
    acmatcher = ACMatcher.new(['999'])
    assert acmatcher.matches?(999)
  end
end

class IPMatcherTest < Minitest::Test
  include Matchers

  def test_matches_when_a_pattern_is_matched
    k1 = '192.168.1.0/24'
    k2 = '255.255.0.0/24'
    kw = [k1, k2]
    matcher = IPMatcher.new(kw)
    assert(matcher.matches?('192.168.1.1'))
    assert(matcher.matches?('255.255.0.255'))
    assert(!matcher.matches?('255.255.255.0'))
  end

  def test_that_blank_pattern_does_not_match
    matcher = ACMatcher.new([''])
    assert(!matcher.matches?('foo'))
  end

  def test_nil_pattern_results_to_no_characters_detected
    matcher = IPMatcher.new(nil)
    assert(!matcher.matches?('192.168.1.0'))
  end

  def test_nil_text_never_matches
    matcher = IPMatcher.new(['192.168.1.0/24'])
    assert(!matcher.matches?(nil))
  end
end
