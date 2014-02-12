# CliCoder

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'clicoder'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install clicoder

## Usage

### Prepare your Makefile

CliCoder uses Makefile to build and execute your program.

#### "build" rule

#### "execute" rule

It has to run your program with redirection from "in.txt" and redirection to "out.txt".

Example:

    execute:
        ./a.out < in.txt > out.txt

#### Sample Makefile

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
