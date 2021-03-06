# CLI Coder

Command Line Interface for Online Programming Contests.

[![Gem Version](https://badge.fury.io/rb/clicoder.svg)](http://badge.fury.io/rb/clicoder)
[![wercker status](https://app.wercker.com/status/8e81d3f6e22f2dfea557c36f78b20fe4/s/master "wercker status")](https://app.wercker.com/project/bykey/8e81d3f6e22f2dfea557c36f78b20fe4)
[![Coverage Status](https://coveralls.io/repos/Genki-S/clicoder/badge.svg)](https://coveralls.io/r/Genki-S/clicoder)
[![Code Climate](https://codeclimate.com/github/Genki-S/clicoder/badges/gpa.svg)](https://codeclimate.com/github/Genki-S/clicoder)
[![Dependency Status](https://gemnasium.com/Genki-S/clicoder.svg)](https://gemnasium.com/Genki-S/clicoder)
[![Inline docs](http://inch-ci.org/github/Genki-S/clicoder.svg?branch=master)](http://inch-ci.org/github/Genki-S/clicoder)

# Why

Programming contests are fun.
However, there are chores which are not fun, like

* copy a sample input and run a program against it
* compare it with a sample answer
* submit (copy & paste or select a file)

This tool automate these chores so that we can enjoy only really fun part of programming contests (which is, thinking and implementing).

# Demo Video

Here is a demo solving a problem from AOJ (links to youtube):

[![CLI Coder demo](http://img.youtube.com/vi/sVH5EIOxDf8/0.jpg)](http://www.youtube.com/watch?v=sVH5EIOxDf8)

# Installation

    $ gem install clicoder

# Preparation

## ~/.clicoder.d/config.yml (required)

It contains

* configurations of template files
* configurations for various programming contest sites.

Example:

```yaml
---
sites:
  default:
      template: template.cpp # template file. relative to this file
  aoj:
      template: aoj_template.cpp # template only used for site 'aoj'
      user_id: Glen_S
      password: PASSWORD
  atcoder:
      user_id: Glen_S
      password: PASSWORD
```

## template.cpp etc. (recommended)

It is recommended to put your template file under `~/.clicoder.d`.
It will be copied into working directories as `main.*` each time you start solving new problems.

If you don't use templates, make sure you write your solutions in files named `main.*`.

# Usage

```sh
Commands:
  clicoder add_test        # Add new test case
  clicoder all             # build, execute, and judge
  clicoder browse          # Open problem page with the browser
  clicoder build           # Build your program
  clicoder download        # Download description, inputs and outputs
  clicoder execute         # Execute your program
  clicoder help [COMMAND]  # Describe available commands or one specific command
  clicoder judge           # Judge your outputs
  clicoder new <command>   # start a new problem
  clicoder submit          # Submit your program
```

## Sites Available

* [AOJ](http://judge.u-aizu.ac.jp/onlinejudge/)
* [AtCoder](http://atcoder.jp/)

```sh
clicoder new aoj PROBLEM_NUMBER # Prepare directory to deal with new problem from AOJ
clicoder new atcoder TASK_URL   # Prepare directory to deal with new problem from AtCoder
```

### AOJ

PROBLEM_NUMBER is shown in problem URL like this:

<pre>http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=<strong>0001</strong></pre>

### AtCoder

TASK_URL is a URL which looks like this:

<pre>http://arc001.contest.atcoder.jp/tasks/arc001_1</pre>

# Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Testing

This repository uses `RSpec` to test application logic and `Cucumber` to test acceptance as a CLI tool.
Make sure both tests passes before submitting pull requests.

```
$ bundle exec rspec spec/
$ bundle exec cucumber features/
```

## Add a Site

It's easy to add new sites.

1. Implement new site class
2. Add it to the factory method (`new_with_config`) in `lib/clicoder/site_base.rb`
3. Add new command (`clicoder new new_site ARGS`) in `lib/clicoder/cli.rb`

Site classes resides in `lib/clicoder/sites` directory.
See existing sites for examples.

You need to implement abstract methods specified in `Clicoder::SiteBase`.

And you need to specify xpaths for description, sample inputs, and sample outputs for a problem of the site you created. You can specify multiple xpaths for sample inputs and sample outputs (those are joined with `|` operator of xpath). Write it in `config/default.yml`, under `xpaths:` section like this:

```
languages:
  ...
xpaths:
  ...
  YOUR_SITE:
    description: YOUR_DESCRIPTION_XPATH
    inputs:
      - YOUR_SAMPLE_INPUTS_XPATH
      - YOUR_SAMPLE_INPUTS_XPATH_2
    outputs:
      - YOUR_SAMPLE_OUTPUTS_XPATH
      - YOUR_SAMPLE_OUTPUTS_XPATH_2
```
