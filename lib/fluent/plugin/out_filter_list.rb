require 'fluent/plugin/out_filter_list/version'
require 'aho_corasick'

module Fluent
  class FilterListOutput < Output
    include Matchers

    Plugin.register_output('filter_list', self)

    config_param :tag_when_filtered, :string, :default => ''
    config_param :key_to_filter, :string, :default => nil
    config_param :patterns_file_path, :string, :default => ''
    config_param :do_retag, :bool, :default => false

    def initialize
      super
    end

    def configure(conf)
      super
      patterns = @patterns_file_path.empty? ? [] : File.readlines(@patterns_file_path).map(&:chomp).reject(&:empty?)
      @matcher = ACMatcher.new(patterns)
    end

    def emit(tag, es, chain)
      es.each do |time, record|
        target = record[@key_to_filter]
        if @matcher.matches?(target) && target
          router.emit(@tag_when_filtered, time, record) unless @tag_when_filtered.empty?
          next
        end
        router.emit(tag, time, record)
      end
    end
  end
end
