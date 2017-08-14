require 'minitest/autorun'

require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts 'Run `bundle install` to install missing gems.'
  exit e.status_code
end

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift File.dirname(__FILE__)

require 'fluent/test'

unless ENV.key?('VERBOSE')
  nulllogger = Object.new
  nulllogger.instance_eval do |_|
    def method_missing(method, *args)
      # pass
      # super
    end

    # def respond_to_missing?(method_name, include_private = false)
    #   super
    # end
  end
  $log = nulllogger
end

require 'fluent/test'
require 'fluent/plugin/out_filter_list'
require 'fluent/plugin/filter_filter_list'
