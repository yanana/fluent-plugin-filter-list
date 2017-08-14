require 'fluent/plugin/out_filter_list/version'
require 'aho_corasick'

module Fluent
  class FilterListFilter < Filter
    include Matchers

    Plugin.register_filter('filter_list', self)

    config_param :key_to_filter, :string, default: nil
    config_param :patterns_file_path, :string, default: ''

    def configure(conf)
      super
      patterns = @patterns_file_path.empty? ? [] : File.readlines(@patterns_file_path).map(&:chomp).reject(&:empty?)
      @matcher = ACMatcher.new(patterns)
    end

    def filter(_tag, _time, record)
      target = record[@key_to_filter]
      return nil if target && @matcher.matches?(target)
      record
    end
  end
end
