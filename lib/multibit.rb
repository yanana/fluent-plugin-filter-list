require 'ffi'
module Multibit
  extend FFI::Library
  ffi_lib 'libmultibit_trie'
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
