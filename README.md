# fluent-plugin-filter-list

[![Build Status](https://travis-ci.org/yanana/fluent-plugin-filter-list.svg?branch=master)](https://travis-ci.org/yanana/fluent-plugin-filter-list)

Want to filter fluentd messages containing black-listed words in the list effectively? Use the _fluent-plugin-filter-list_ plugin. The plugin enables you to filter messages in the list of words you provide. You can either discard such messages simply, or process them in a different flow by retagging them.

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

This repository contains two plugins: _Filter_ and _Output_, and expects two main use cases.

### Filter plugin

Use the `filter_list` filter. Configure fluentd as follows.

#### ACMatcher
```
<filter pattern>
  @type filter_list

  filter AC
  key_to_filter x
  pattern_file_paths ["blacklist_1.txt", "blacklist_2.txt"]
  filter_empty true
</filter>
```

Given the `blacklist.txt` is as follows.

```
foo
bar
buzz
```

The following message is discarded since its `x` field contains the sequence of characters _bar_, contained in the list.

```json
{
  "x": "halbart",
  "y": 1
}
```

While the following message is passed through as the target field specified in the config is not _y_ but _x_.

```json
{
  "x": 1,
  "y": "halbart"
}
```

Additionally, the following message is also omitted since `filter_empty` is `true`. The value is determined to be empty when the trimed value is empty.

```json
{
  "x": "   ",
  "y": "halbart"
}
```

#### IPMatcher
```
<filter pattern>
  @type filter_list

  filter IP
  key_to_filter ip
  pattern_file_paths blacklist.txt
</filter>
```

Given the `blacklist.txt` is as follows.

```
192.168.1.0/24
127.0.0.1/24
255.255.0.0
```

The following message is discarded since its `ip` field is the IP address in the list (exact IP).

```json
{
  "ip": "255.255.0.0",
  "y": 1
}
```

Also the following message is discarded since its `ip` field is the IP address in the list (CIDR-notated IP).

```json
{
  "ip": "192.168.1.255",
  "y": 1
}
```

While the following message is passed through.

```json
{
  "ip": "192.168.2.0",
  "y": 1
}
```

### Output plugin

The other use case is to filter messages likewise, but process the filtered messages in a different tag. You need to configure the plugin to tell it how to retag both non-filtered messages and filtered messages. We provide two mutually-exclusive parameters: `tag` and `add_prefix`. THe `tag` parameter tells the plugin to retag the message with the value exactly provided by the parameter. The `add_prefix` parameter tells the plugin to retag the messages with the original tag prepended with the value you provide. So if the original message had a tag _foo_ and you set the `add_prefix` parameter _filtered_, then the processed message would have the tag _filtered.foo_ (note that the period before the original tag value is also prepended).

```
<match pattern>
  @type filter_list

  key_to_filter field_name_you_want_to_filter
  pattern_file_paths ["file_including_patterns_separated_by_new_line"]
  filter_empty true

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
