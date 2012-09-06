# Monkeypuzzles

A website of puzzles. Ruby on rails is big... and seems clumsy. Moving to
Sinatra. The site can be seen live at
[monkeypuzzles.herokuapp.com](http://monkeypuzzles.herokuapp.com/).  A proper
domain name will be acquired later.

## Setup and Coding

[RVM](https://rvm.io/) is the recommended way of installing ruby. It will
sandbox each project with their own ruby and gem versions. But it is (probably)
not required.

Then:

	git clone git@github.com:tgwizard/monkeypuzzles.git
	cd monkeypuzzles
	# install bundler if not already installed
	gem install bundler
	# install all dependencies from the Gemfile
	bundle install
	# start the dev server
	rake sinatra
	# go to http://localhost:4567

The code is built on [ruby](http://www.ruby-lang.org/en/), and uses the
[sinatra](http://sinatrarb.com) and
[bootstrap](http://twitter.github.com/bootstrap) frameworks. If more is
required, [padrino](http://www.padrinorb.com/) is probably the way to go.

## Deployment

	git pull --rebase
	# check that everything is ok
	git push && git push heroku
	# done!
