require 'ipaddr'
require 'ip'

module Matchers
  class ACMatcher
    attr_reader :trie

    def initialize(patterns)
      patterns = (patterns || []).compact.reject(&:empty?)
      @machine = ACAutomaton.new patterns
    end

    def matches?(text)
      return false if text.nil? || text == ''

      @machine.matches? text.to_s
    end

    def find(text)
      return false if text.nil? || text == ''

      @machine.find(text)
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
    class Node
      attr_reader :children

      def initialize
        @children = {}
        @children.default = nil
      end

      def insert(char)
        @children[char] = Node.new unless @children.key?(char)
        @children[char]
      end

      def forward(str)
        children = @children
        child = nil
        str.chars.each do |char|
          child = children[char]
          children = child.children
        end
        child
      end
    end

    attr_reader :root

    def initialize(patterns)
      @root = Node.new
      @root.children.default = @root
      patterns.each do |pattern|
        insert(pattern)
      end
    end

    def insert(pattern = '')
      current_node = @root
      pattern.chars.each do |char|
        current_node = current_node.insert(char)
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

  # An AC automaton.
  # Based on https://www.cs.uku.fi/~kilpelai/BSA05/lectures/slides04.pdf.
  class ACAutomaton
    class Node
      # Manages the goto as a character -> node ID mapping.
      attr_reader :goto
      # Uniquely (in an automaton) assigned ID of the Node.
      attr_reader :id
      attr_accessor :failure
      # Stores out of AC, that is the index of the patterns.
      attr_accessor :out

      def initialize(id: 0, goto: {}, failure: 0, out: [])
        @id = id
        @goto = goto
        @failure = failure
        @out = out
      end

      def root?
        @id.zero?
      end

      def g(char)
        if (next_node = @goto[char])
          return next_node
        end
        return 0 if root?

        nil
      end

      def to_s
        "id: #{@id}, goto: #{@goto}, failure: #{@failure}, out: #{@out}"
      end

      def ==(other)
        @id == other.id && @goto == other.goto && @failure == other.failure && @out == other.out
      end
    end
    # Nodes are managed in an array. The indices are
    attr_reader :nodes, :patterns

    def initialize(patterns)
      @nodes = []
      @patterns = patterns || []
      build(@patterns)
    end

    # Creates a new node and returns the id.
    # This method is not thread safe.
    def new_node
      id = @nodes.size
      node = Node.new(id: id)
      @nodes.push(node)
      id
    end

    def build(patterns)
      build_goto(patterns)
      build_failure
    end

    def build_goto(patterns)
      root = new_node
      patterns.each_with_index do |pattern, i|
        q = root
        pattern.chars.each do |char|
          next_q = @nodes[q].goto[char]
          if next_q
            q = next_q
          else
            new_q = new_node
            @nodes[q].goto[char] = new_q
            q = new_q
          end
        end

        @nodes[q].out.push(i)
      end
    end

    def build_failure
      queue = [0]
      until queue.empty?
        n = queue.shift
        node = @nodes[n]
        @nodes[n].goto.each do |c, next_node|
          queue.push(next_node)

          next if n.zero?

          failure = node.failure
          failure = @nodes[failure].failure while @nodes[failure].g(c).nil?
          @nodes[next_node].failure = @nodes[failure].g(c)
          @nodes[next_node].out.concat(@nodes[@nodes[next_node].failure].out)
        end
      end
    end

    def find(text)
      return [] if text.nil? || text == ''

      find_id(text).map do |id|
        @patterns[id]
      end
    end

    # Finds and retuns matched pattens' indices.
    def find_id(text)
      return [] if text.nil? || text == ''

      q = 0
      result = []
      text.chars.each_with_index do |c, _i|
        loop do
          node = @nodes[q]
          if (to_go_next = node.goto[c])
            q = to_go_next
            break
          end
          break if q.zero?

          q = node.failure
        end

        out = @nodes[q].out
        result.concat(out) unless out.empty?
      end

      result
    end

    # Returns true if the text matches any pattern, otherwise false.
    def matches?(text)
      return false if text.nil?

      q = 0
      text.chars.each do |c|
        loop do
          node = @nodes[q]
          if (to_go_next = node.goto[c])
            q = to_go_next
            break
          end
          break if q.zero?

          q = node.failure
        end

        out = @nodes[q].out

        return true unless out.empty?
      end

      false
    end
  end
end
