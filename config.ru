require './src/main.rb'
$stdout.sync = true

use Rack::CanonicalHost, ENV['CANONICAL_HOST'] if ENV['CANONICAL_HOST']
run Sinatra::Application
