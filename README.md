# Marc::Dates

This gem parses MARC dates into `Time` objects.

Formats supported by this gem were gleaned from a few 100,000 MARC records at
one institution only. There are sure to be vast numbers of formats it can't
parse. Nevertheless, the error rate on this data set is less than 1%.

Development is governed by a Pareto distribution whereby 1% of formats will
consume 99% of development effort.

MARC dates contain a lot of information about ambiguities. This is all lost
during parsing, and any missing information is treated as zero.

## Installation

Add this line to your application's Gemfile:

```
gem 'marc-dates'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install marc-dates

## Usage

```
> Marc::Dates::parse('[1923?]')
 => [1923-01-01 00:00:00 -0600] 

> Marc::Dates::parse('1923-c1932')
 => [1923-01-01 00:00:00 -0600, 1932-01-01 00:00:00 -0600] 

> Marc::Dates::parse('[between 1923 and 1932]')
 => [1923-01-01 00:00:00 -0600, 1932-01-01 00:00:00 -0600] 

> Marc::Dates::parse('MDCCCCXXIII')
 => [1923-01-01 00:00:00 -0600]
```

### Error handling

```ruby
begin
  Marc::Dates::parse('[1923?]')
rescue Marc::Dates::FormatError
  # The date could not be parsed. 
rescue ArgumentError
  # This indicates a bug in the library.
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then,
run `rake test` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then
run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/medusa-project/marc-dates. If you do submit a pull request,
please include tests for your changes.
