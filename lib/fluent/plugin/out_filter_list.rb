require 'fluent/plugin/out_filter_list/version'
require 'aho_corasick'

module Fluent
  class FilterListOutput < Output
    include Matchers

    Plugin.register_output('filter_list', self)

    config_param :key_to_filter, :string, :default => nil
    config_param :patterns_file_path, :string, :default => ''

    config_section :retag, required: true, multi: false do
      config_param :tag, :string, :default => nil
      config_param :add_prefix, :string, :default => nil
    end

    config_section :retag_filtered, param_name: :retag_for_filtered, required: false, multi: false do
      config_param :tag, :string, :default => nil
      config_param :add_prefix, :string, :default => nil
    end

    def initialize
      super
    end

    def validate(retag)
      if !retag
        return
      end
      if !(retag.tag || retag.add_prefix)
        raise Fluent::ConfigError, "missing tag and add_prefix"
      end
      if retag.tag && retag.add_prefix
        raise Fluent::ConfigError, "tag and add_prefix are mutually exclusive"
      end
    end

    def configure(conf)
      super
      [@retag, @retag_for_filtered].each { |c| validate c }
      patterns = @patterns_file_path.empty? ? [] : File.readlines(@patterns_file_path).map(&:chomp).reject(&:empty?)
      @matcher = ACMatcher.new(patterns)
      if @retag_for_filtered && @retag_for_filtered.add_prefix
        @prefix_for_filtered_tag = @retag_for_filtered.add_prefix + "."
      end
      if @retag && @retag.add_prefix
        @prefix = @retag.add_prefix + "."
      end
    end

    def emit(tag, es, chain)
      es.each do |time, record|
        target = record[@key_to_filter]
        # Do filter
        if target && @matcher.matches?(target)
          if @retag_for_filtered
            tag = @retag_for_filtered.tag || ((tag && !tag.empty?) ? @prefix_for_filtered_tag + tag : @retag_for_filtered.add_prefix)
            router.emit(tag, time, record)
          end
          next
        end
        tag = @retag.tag || ((tag && !tag.empty?) ? @prefix + tag : @retag.add_prefix)
        router.emit(tag, time, record)
      end
    end
  end
end
