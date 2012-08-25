require 'rubygems'
require 'bundler/setup'

require 'sinatra'

get '/' do
	#"Hello world, it's Sinatra speaking at #{Time.now}"
	erb :index
end
