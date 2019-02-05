require 'ffi'
module Multibit
  extend FFI::Library
  ffi_lib 'target/release/libmultibit_trie.dylib'
  attach_function :make_fixedstridemultibit, [:uint], :pointer
  attach_function :insert, %i[pointer string], :void
  attach_function :search, %i[pointer string], :bool

  class MultiBitTrie
    def initialize(size)
      @trie = Multibit.make_fixedstridemultibit(size)
    end

    def insert(binary)
      Multibit.insert(@trie, binary)
    end

    def search(binary)
      Multibit.search(@trie, binary)
    end
  end
end

trie = Multibit::MultiBitTrie.new(3)
trie.insert('10000')
p trie.search('100010')
trie.insert('100')
p trie.search('100010')
