# CLI Coder

Command Line Interface for Online Programming Contests.

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
default:
    template: template.cpp # template file. relative to this file
    makefile: Makefile # Makefile used by CLI Coder. relative to this file
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

## Makefile (required)

It is recommended to put your `Makefile` under `~/.clicoder.d`.

CLI Coder uses Makefile to build and execute your program.

## "build" rule

It should build your program.

Example:

    build:
        g++ -g main.cpp -o a.out

## "execute" rule

It has to run your program with redirection from "in.txt" and redirection to "out.txt".

Example:

    execute:
        ./a.out < in.txt > out.txt

# Usage

```sh
Commands:
  clicoder add_test        # Add new test case
  clicoder all             # build, execute, and judge
  clicoder browse          # Open problem page with the browser
  clicoder build           # Build your program using `make build`
  clicoder download        # Download description, inputs and outputs
  clicoder execute         # Execute your program using `make execute`
  clicoder help [COMMAND]  # Describe available commands or one specific command
  clicoder judge           # Judge your outputs
  clicoder new <command>   # start a new problem
  clicoder submit          # Submit your program
```

## Sites Available

* [AOJ](http://judge.u-aizu.ac.jp/onlinejudge/)
* [AtCoder](http://atcoder.jp/)

```sh
clicoder new aoj PROBLEM_NUMBER                 # Prepare directory to deal with new problem from AOJ
clicoder new atcoder CONTEST_ID PROBLEM_NUMBER  # Prepare directory to deal with new problem from AtCoder
```

### AOJ

PROBLEM_NUMBER is shown in problem URL like this:

<pre>http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=<strong>0001</strong></pre>

### AtCoder

CONTEST_ID is shown in contest URL like this:

<pre>http://<strong>arc001</strong>.contest.atcoder.jp/</pre>

PROBLEM_NUMBER is a number starting from 1, or it can be found in problem URL like this:

<pre>http://arc001.contest.atcoder.jp/tasks/arc001_<strong>1</strong></pre>

# Tips

I recommend you to use this shell function for AOJ:

```sh
function aoj() {
    clicoder new aoj $1
    dir=$(printf "%04d" $1)
    cd $dir
}
```

# Contributing

**Please send your pull requests to "develop" branch.**
Thank you for your contributions.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Add a Site

It's easy to add new sites.

1. Implement new site class
2. Add it to the factory method (`new_with_config`) in `lib/clicoder/site_base.rb`
3. Add new command (`clicoder new new_site ARGS`) in `lib/clicoder/cli.rb`

Site classes resides in `lib/clicoder/sites` directory.
See existing sites for examples.

Basically, you need to implement these methods:

### initialize

Initialize a site instance (i.e. a problem) and set local configurations (like problem id).

### submit

Submit your code.

### open_submission

Open submission status page. This will be called automatically after successful submissions.

### login

Sometimes you need to login to see problems or to submit your solutions.
This method has to log in and execute given block under logged-in condition.

### site_name

Returns site name.

### problem_url

Returns problem url.

### description_xpath

Returns xpath which indicates where the problem description is.
Used to download problem description.

### inputs_xpath

Returns xpath which indicates where the sample inputs are.
Used to download sample inputs.

### outputs_xpath

Returns xpath which indicates where the sample outputs are.
Used to download sample outputs.

### working_directory

Returns a directory name it should create with `clicoder new` command.
