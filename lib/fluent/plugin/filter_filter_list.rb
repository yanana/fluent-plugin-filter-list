require 'fluent/plugin/out_filter_list/version'
require 'matcher'
require 'fluent/plugin/filter'
require 'ip'

module Fluent
  module Plugin
    class FilterListFilter < Filter
      include Matchers
      include IP

      Plugin.register_filter('filter_list', self)

      config_param :filter, :string, default: 'AC'
      config_param :key_to_filter, :string, default: nil
      config_param :patterns_file_path, :string, default: ''
      config_param :filter_empty, :bool, default: false

      def configure(conf)
        super
        patterns = @patterns_file_path.empty? ? [] : File.readlines(@patterns_file_path).map(&:chomp).reject(&:empty?)
        @matcher = (@filter == 'IP') ? IPMatcher.new(patterns) : ACMatcher.new(patterns)
      end

      def filter(_tag, _time, record)
        target = record[@key_to_filter]
        return nil if target && (@matcher.matches?(target) || (@filter_empty && target.strip.empty?))
        record
      end
    end
  end
end
