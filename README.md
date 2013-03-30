# Ruby Date/Time Precision [![Build Status](https://travis-ci.org/Spokeo/date_time_precision.png?branch=master)](https://travis-ci.org/Spokeo/date_time_precision)

Sometimes it is desirable to manipulate dates or times for which incomplete information is known.
For example, one might only know the year, or the year and the month.
Unfortunately, Ruby's built-in Date, Time, and DateTime classes do not keep track of the precision of the data.
For example:

```ruby
Date.new.to_s        # => "-4712-01-01"
Date.new(2000).to_s  # => "2000-01-01"
```

There is no way to tell the difference between January 1, 2000 and a Date where only the year 2000 was known.

The DateTimePrecision gem patches the Date, Time, DateTime, and NilClass classes to keep track of precision.
The behavior of these classes should otherwise remain unchanged.

## Usage

```ruby
require 'date_time_precision'

d = Date.new(2000)
d.precision  # => DateTimePrecision::YEAR

t = Time::parse("2001-05")
t.precision  # => DateTimePrecision::MONTH
t.precision > d.precision # => true

dt = DateTime.new(nil, 7, 4)
dt.year?     # => false
dt.month?    # => true
```

The gem adds the following instance methods to Date, Time, and/or DateTime:

*    precision
*    precision=
*    partial_match?
*    year?
*    month?
*    day?
*    hour?
*    min?
*    sec?

## Formats

It is useful to convert the various time classes into other formats that preserve the precision.
The currently supported formats are Hash, JSON, and ISO 8601.

Examples:

```ruby
require 'date_time_precision/format/hash'

date = Date.new(2000, 10)
hash = date.to_h
# => {:year=>2000, :mon=>10}

hash.to_date.precision
# => 2

birthday = Date.new(nil, 11, 12)
birthday.to_h
# => {:mon => 11, :day => 12}
```

```ruby
require 'date_time_precision/format/json'

date = Date.new(2000, 10)
puts json = date.to_json
# => {"year":2000,"mon":10}

JSON.parse(json).to_date.precision
# => 2
```

```ruby
require 'date_time_precision/format/iso8601'

Date.new(2000, 5).iso8601
# => "2000-05"
```

## Ruby Compatibility

Tested in MRI 1.8.7/1.9.2/1.9.3/2.0.0, REE, JRuby 1.8/1.9, and Rubinius 1.8/1.9.

Note that starting in MRI 1.9.3, the core Date/Time classes were rewritten in C, making it difficult to
override internal functionality. Some functions are now implemented internally and are not exposed.
The workaround is inefficient: `#parse` and `#strptime` perform the same work twice, once to get the precision and once inside the original C method.

## Gem Compatibility

Sometimes other gems will use the Date/Time class in ways that don't preserve precision. If you want to use the DateTimePrecision gem with these
gems, any compatibility issues will most likely need to be patched within DateTimePrecision itself. This is because DateTimePrecision makes some
modifications to how the core Date/Time classes work. (For example, by allowing nil values to be passed to constructors.)

So far, the following gems are on the compatibility watch list:

 - [x] [ActiveSupport](https://github.com/rails/rails/tree/master/activesupport)
 - [x] [Virtus](https://github.com/solnic/virtus)
 - [x] [Coercible](https://github.com/solnic/coercible)
 - [ ] [Chronic](https://github.com/mojombo/chronic)
 - [ ] [Timeliness](https://github.com/adzap/timeliness)
 - [ ] [Timecop](https://github.com/travisjeffery/timecop)

If you know of any others, feel free to submit a pull request!

## Installation

Add this line to your application's Gemfile:

    gem 'date_time_precision'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install date_time_precision

## Wishlist

 - [x] Support Time::mktime
 - [x] Support Time::utc and Time#utc
 - [x] Support Time::local
 - [.] Support correct generation (done) and parsing (not done) of the ISO 8601 format, which supports partial dates
 - [ ] Support the various time zone methods (partially done)
 - [ ] Support easy string formatting based on precision

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
