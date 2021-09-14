require 'test_helper'
require 'matcher'

class ACMatcherTest < Minitest::Test
  include Matchers

  def test_that_tree_without_leaves_is_built_given_nil_is_passed
    ac = ACAutomaton.new(nil)
    assert(ac.nodes[0].goto.empty?)
  end

  def test_that_tree_without_leaves_is_built_given_empty_array_is_passed
    acm = ACAutomaton.new([])
    assert(acm.nodes[0].goto.empty?)
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

  def test_not_matches_when_a_text_is_invalid_encoding
    patterns = %w[foo bar]
    matcher = ACMatcher.new(patterns)
    # Create invalid UTF-8 byte sequence
    text = "あ\244\255\192\193い".force_encoding('UTF-8')
    assert(matcher.matches?(text) == false)
  end

  def test_matches_when_a_pattern_is_at_the_head_of_text
    k1 = 'hoge'
    k2 = 'bar'
    kw = [k1, k2]
    acmatcher = ACMatcher.new(kw)
    assert(acmatcher.matches?("#{k1}abc"))
    assert(acmatcher.matches?("#{k2}abc"))
    assert(!acmatcher.matches?('abcabc'))
  end

  def test_matches_when_a_pattern_is_at_the_tail_of_text
    k1 = 'hoge'
    k2 = 'bar'
    kw = [k1, k2]
    acmatcher = ACMatcher.new(kw)
    assert(acmatcher.matches?("abc#{k1}"))
    assert(acmatcher.matches?("abc#{k2}"))
    refute(acmatcher.matches?('abcabc'))
  end

  def test_that_blank_pattern_does_not_match
    acmatcher = ACMatcher.new([''])
    refute(acmatcher.matches?('foo'))
  end

  def test_nil_pattern_results_to_no_characters_detected
    acmatcher = ACMatcher.new(nil)
    refute(acmatcher.matches?('foo'))
  end

  def test_nil_text_never_matches
    matcher = ACMatcher.new(['xyz'])
    refute matcher.matches?(nil)
  end

  def test_blank_text_never_matches
    matcher = ACMatcher.new(['foo'])
    refute(matcher.matches?(''))
  end

  def test_text_other_than_string_is_converted_to_string_before_comparison
    acmatcher = ACMatcher.new(['999'])
    assert acmatcher.matches?(999)
  end

  def test_patterns_consisting_of_an_arbitrary_text_and_its_substrings
    m = ACMatcher.new(%w[xy axyz])
    assert(m.matches?('xy'))
    assert(m.matches?('axyz'))
    assert(m.matches?('axyk'))
    assert(m.matches?('axy'))
    assert(m.matches?('bxy'))
    assert(m.matches?('xyz'))
    refute(m.matches?('yz'))
    refute(m.matches?('ax'))
    refute(m.matches?('axc'))
    refute(m.matches?('x'))
    refute(m.matches?('y'))
  end

  def test_failure_link
    m = ACMatcher.new(%w[xyz abxyz])
    assert(m.matches?('xyz'))
    assert(m.matches?('axyz'))
    refute(m.matches?('abxee'))
    assert(m.matches?('abxeexyz'))
  end

  def test_find_nothing_matched
    p = %w[she]
    text = 'bad'
    m = ACMatcher.new(p)
    assert_equal([], m.find(text))
  end

  def test_find_exact_match
    p = %w[she]
    text = 'she'
    m = ACMatcher.new(p)
    assert_equal(%w[she], m.find(text))
  end

  def test_find_partial_match
    p = %w[she]
    text = 'sh'
    m = ACMatcher.new(p)
    assert_equal([], m.find(text))
  end

  def test_build
    p = %w[hers his she he]
    ac = ACAutomaton.new(p)
    nodes = [
      ACAutomaton::Node.new(id: 0, goto: { 'h' => 1, 's' => 7 }, failure: 0, out: []),
      ACAutomaton::Node.new(id: 1, goto: { 'e' => 2, 'i' => 5 }, failure: 0, out: []),
      ACAutomaton::Node.new(id: 2, goto: { 'r' => 3 }, failure: 0, out: [3]),
      ACAutomaton::Node.new(id: 3, goto: { 's' => 4 }, failure: 0, out: []),
      ACAutomaton::Node.new(id: 4, goto: {}, failure: 7, out: [0]),
      ACAutomaton::Node.new(id: 5, goto: { 's' => 6 }, failure: 0, out: []),
      ACAutomaton::Node.new(id: 6, goto: {}, failure: 7, out: [1]),
      ACAutomaton::Node.new(id: 7, goto: { 'h' => 8 }, failure: 0, out: []),
      ACAutomaton::Node.new(id: 8, goto: { 'e' => 9 }, failure: 1, out: []),
      ACAutomaton::Node.new(id: 9, goto: {}, failure: 2, out: [2, 3])
    ]
    nodes.each do |node|
      n = ac.nodes[node.id]
      assert_equal(node, n)
    end
  end

  def test_find
    ps = %w[she her hers he]
    m = ACAutomaton.new ps
    assert_equal(%w[he she], m.find('kasheh').sort)
  end

  def test_matches
    ps = %w[bot efg Googlew]
    m = ACAutomaton.new ps
    assert(m.matches?('Googlebot'))
    refute(m.matches?('Google'))
  end
end

class IPMatcherTest < Minitest::Test
  include Matchers

  def test_matches_when_a_pattern_is_matched
    k1 = '192.168.1.0/24'
    k2 = '255.255.0.0/24'
    k3 = '52.167.0.0/16'
    k4 = '43.90.0.0/16' # 00101011.01011010.00000000.00000000
    kw = [k1, k2, k3, k4]
    matcher = IPMatcher.new(kw)
    assert(matcher.matches?('192.168.1.1'))
    refute(matcher.matches?('192.168.2.1'))
    assert(matcher.matches?('255.255.0.255'))
    refute(matcher.matches?('255.255.255.0'))
    refute(matcher.matches?('210.156.120.95'))
    assert(matcher.matches?('43.90.1.254'))
    refute(matcher.matches?('173.104.1.254'))
    refute(matcher.matches?('86.180.1.254'))
  end

  def test_that_blank_pattern_does_not_match
    matcher = ACMatcher.new([''])
    refute(matcher.matches?('foo'))
  end

  def test_nil_pattern_results_to_no_characters_detected
    matcher = IPMatcher.new(nil)
    refute(matcher.matches?('192.168.1.0'))
  end

  def test_nil_text_never_matches
    matcher = IPMatcher.new(['192.168.1.0/24'])
    refute(matcher.matches?(nil))
  end
end
