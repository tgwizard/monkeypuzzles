# Monkeypuzzles

A website of puzzles. Ruby on rails is big... and seems clumsy. Moving to
Sinatra. The site can be seen live at
[monkeypuzzles.org](http://monkeypuzzles.org).  A proper
domain name will be acquired later.

## Setup and Coding

[RVM](https://rvm.io/) is the recommended way of installing ruby. It will
sandbox each project with their own ruby and gem versions. But it is (probably)
not required.

Sqlite is used for development, and bindings for it can be installed like this,
according to the [DataMapper startup
guide](http://datamapper.org/getting-started.html):

  # Debian / Ubuntu
  sudo apt-get install libsqlite3-dev

  # RedHat / Fedora
  sudo yum install sqlite-devel

  # MacPorts
  sudo port install sqlite3

  # HomeBrew
  sudo brew install sqlite

Then:

  git clone git@github.com:tgwizard/monkeypuzzles.git
  cd monkeypuzzles
  # install bundler if not already installed
  gem install bundler
  # install all dependencies from the Gemfile
  bundle install
  # start the dev server, after each change
  rake sinatra
  # go to http://localhost:4567

You can also start the dev server with `shotgun`, like this:

  rake shotgun
  # go to http://localhost:4567

With shotgun, the server reloads on each request. This might make it easier to
develop, but it is unfortunately quite slow.

The development sqlite database is stored in `dev.db`. Datamapper migrations
don't work that well with sqlite, so it might need to be removed from time to
time. You might need to clear your browser's cache after that.

[monkeypuzzles.org/status](http://monkeypuzzles.org/status) gives some overview
of the system status - including database content.

When logging in, [mockmyid.com](http://mockmyid.com) is a good way to get a
fake email.

The code is built on [ruby](http://www.ruby-lang.org/en/), and uses the
[sinatra](http://sinatrarb.com), [DataMapper](http://datamapper.org) and
[bootstrap](http://twitter.github.com/bootstrap) frameworks.

## Deployment

  git pull --rebase
  # check that everything is ok
  git push && git push heroku
  # done!
