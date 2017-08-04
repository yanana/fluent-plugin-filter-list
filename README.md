# fluent-plugin-filter-list

[![Build Status](https://travis-ci.org/yanana/fluent-plugin-filter-list.svg?branch=master)](https://travis-ci.org/yanana/fluent-plugin-filter-list)

[Fluentd](http://fluentd.org/) output plugin that filters messages whose value of specified field matches values in a list of patterns (like agrep). This plugin not only filters messages and discards them but also provides the feature to retag filtered records.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fluent-plugin-filter-list'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fluent-plugin-filter-list

## Usage

```
<match your_tag>
  @type filter_list
  
  key_to_filter field_name_you_want_to_filter
  patterns_file_path file_including_patterns_separated_by_new_line
  
  <retag>
    add_prefix x # retag non-filtered messages whose tag will be "x.your_tag"
  </retag>
  <retag_filtered>
    tag y # simply retag filtered (matched) messages with "y"
  </retag_filtered>
</match>
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yanana/fluent-plugin-filter-list. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
