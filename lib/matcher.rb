require 'ipaddr'
require 'ip'

module Matchers
  class ACMatcher
    attr_reader :trie

    def initialize(patterns)
      patterns = (patterns || []).compact.reject(&:empty?)
      @trie = Trie.new patterns
    end

    def matches?(text)
      node = @trie.root
      text.to_s.chars.each do |char|
        failure = node.failure
        node = node.children[char]

        return true unless node.nil? || node.output.nil?
        return true unless failure.nil? || failure.output.nil?

        # Follow failure if it exists in case pattern doesn't match
        node = failure if node.nil?
      end

      return false if node.failure.nil?

      !node.failure.output.nil?
    end
  end

  class IPMatcher
    attr_reader :trie

    include IP

    def initialize(patterns)
      patterns = (patterns || []).compact.reject(&:empty?).map { |ip| IP.new(ip) }.map(&:to_binary)
      @trie = Trie.new patterns
    end

    def matches?(text)
      return false if text.nil?

      ip = IPAddr.new(text).to_i.to_s(2).rjust(32, '0')
      trie.forward_match(ip)
    end
  end

  class Trie
    attr_reader :root

    def initialize(patterns)
      @root = Node.new
      @root.children.default = @root
      patterns.each do |pattern|
        insert(pattern)
      end
      build
    end

    def insert(pattern = '')
      current_node = @root
      pattern.chars.each_with_index do |char, i|
        current_node = current_node.insert(char)
        current_node.output = pattern if i == pattern.length - 1
      end
    end

    def new_queue
      q = Queue.new
      @root.children.each_value do |child|
        q.push(child)
        child.failure = @root # set root on root's children's failure
      end
      q
    end

    def build
      # Update failure on each node.
      # Search longest matching suffix (which becomes failure) by BFS. In case no matching suffix, root becomes failure.
      q = new_queue
      until q.empty?
        cur_node = q.pop
        cur_node.children.each do |char, child|
          q.push(child)
          detect_node = cur_node.failure || @root
          detect_node = detect_node.failure while detect_node.children[char].nil?
          child.failure = detect_node.children[char]
        end
      end
    end

    def forward_match(pattern)
      return false if @root.children.empty?

      cur_node = @root
      pattern.chars.each do |char|
        return true if cur_node.children.empty?
        return false unless cur_node.children.key?(char)

        cur_node = cur_node.children[char]
      end
      true
    end
  end

  class Node
    attr_reader :children
    attr_accessor :failure, :output

    def initialize
      @children = {}
      @children.default = nil
      @output = nil
      @failure = nil
    end

    def insert(char)
      @children[char] = Node.new unless @children.key?(char)
      @children[char]
    end
  end
end
