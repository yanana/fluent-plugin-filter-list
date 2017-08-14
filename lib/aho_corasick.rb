module Matchers
  class ACMatcher
    attr_reader :trie

    def initialize(patterns)
      patterns = (patterns || []).compact.reject(&:empty?)
      @trie = Trie.new patterns
    end

    def matches?(text)
      node = @trie.root
      text.to_s.split('').each do |char|
        node = node.failure while node.children[char].nil? # Follow failure if it exists in case pattern doesn't match
        node = node.children[char]
        return true unless node.output.nil?
      end
      false
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
      pattern.split('').each_with_index do |char, i|
        current_node = current_node.insert(char)
        if i == pattern.length - 1
          current_node.output = pattern
        end
      end
    end

    def new_queue
      q = Queue.new
      @root.children.values.each do |child|
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
          while detect_node.children[char].nil?
            detect_node = detect_node.failure
          end
          child.failure = detect_node.children[char]
        end
      end
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
