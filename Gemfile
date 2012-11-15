source :rubygems

# Server requirements
gem 'thin' # or mongrel
# gem 'trinidad', :platform => 'jruby'

# Project requirements
gem 'rake'
gem 'sinatra-flash', :require => 'sinatra/flash'
gem 'redcarpet'
gem 'rack-canonical-host'
gem 'rack_csrf'
gem 'nestful'

# Component requirements
gem 'haml'
gem 'activerecord', :require => "active_record"

# Test requirements
gem 'newrelic_rpm'

# Padrino Stable Gem
gem 'padrino', '0.10.7'

# Or Padrino Edge
# gem 'padrino', :git => 'git://github.com/padrino/padrino-framework.git'

# Or Individual Gems
# %w(core gen helpers cache mailer admin).each do |g|
#   gem 'padrino-' + g, '0.10.7'
# end

# Development requirements
group :development, :test do
  gem 'sqlite3'
end

# Production requirements
group :production do
  gem 'pg'
end
