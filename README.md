# Monkeypuzzles

A website of puzzles. The site can be seen live at
[monkeypuzzles.org](http://monkeypuzzles.org).

## Setup and Coding

The code is built on [ruby](http://www.ruby-lang.org/en/).
[RVM](https://rvm.io/) is the recommended way of installing ruby. It will
sandbox each project with their own ruby and gem versions. But it is (probably)
not required.

We use [padrino](http://padrinorb.com) and
[bootstrap](http://twitter.github.com/bootstrap).


Sqlite is used for development, and bindings for it can be installed like this,
according to the [DataMapper startup
guide](http://datamapper.org/getting-started.html):

~~~ bash
# Debian / Ubuntu
sudo apt-get install libsqlite3-dev
# RedHat / Fedora
sudo yum install sqlite-devel
# MacPorts
sudo port install sqlite3
# HomeBrew
sudo brew install sqlite
~~~

Then:

~~~ bash
git clone git@github.com:tgwizard/monkeypuzzles.git
cd monkeypuzzles
# install bundler if not already installed
gem install bundler
# install development dependencies from the Gemfile
bundle install --without production
# run migrations
padrino rake ar:migrate
# start the dev server, after each change
padrino s
# go to http://localhost:3000
~~~


[monkeypuzzles.org/status](http://monkeypuzzles.org/status) gives some overview
of the system status - including database content.

When logging in, [mockmyid.com](http://mockmyid.com) is a good way to get a
fake email.

## Deployment

~~~ bash
git pull --rebase
# check that everything is ok
git push && git push heroku master
heroku rake ar:migrate
# done!
~~~
