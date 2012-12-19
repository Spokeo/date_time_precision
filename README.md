# Ruby Date/Time Precision [![Build Status](https://travis-ci.org/Spokeo/date_time_precision.png?branch=master)](https://travis-ci.org/Spokeo/date_time_precision)

Sometimes it is desirable to manipulate dates or times for which incomplete information is known.
For example, one might only know the year, or the year and the month.
Unfortunately, Ruby's built-in Date, Time, and DateTime classes do not keep track of the precision of the data.
For example:

```ruby
Date.new.to_s         => "-4712-01-01"
Date.new(2000).to_s   => "2000-01-01"
```

There is no way to tell the difference between January 1, 2000 and a Date where only the year 2000 was known.

The DateTimePrecision gem patches the Date, Time, DateTime, and NilClass classes to keep track of precision.
The behavior of these classes should remain unchanged, and the following methods are now available:

*    precision
*    precision=
*    partial_match?
*    year?
*    month?
*    day?
*    hour?
*    min?
*    sec?

## Compatibility

Tested in MRI 1.8.7/1.9.2/1.9.3, REE, JRuby 1.8/1.9, and Rubinius 1.8/1.9.

Note that starting in MRI 1.9.3, the core Date/Time classes were rewritten in C, making it difficult to
override internal functionality. Some functions are now implemented internally and are not exposed.
The workaround is inefficient: `#parse` and `#strptime` perform the same work twice, once to get the precision and once inside the original C method.

## Installation

Add this line to your application's Gemfile:

    gem 'date_time_precision'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install date_time_precision
 
## Usage

```ruby
require 'date_time_precision'

d = Date.new(2000)
d.precision # => DateTimePrecision::YEAR

t = Time::parse("2001-05")
t.precision # => DateTimePrecision::MONTH
t.precision > d.precision # => true
```

## Wishlist

*   Support Time::mktime, Time::utc, Time::local
*   Support easy string formatting based on precision

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
