require_relative '../src/main'
require 'test/unit'
require 'rack/test'
require 'set'

ENV['RACK_ENV'] = 'test'

class AvailabilityTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_it_says_enjoy
    get '/'
    assert last_response.ok?
    assert last_response.body.include?('Enjoy!')
  end

  def test_no_404s
    visited_urls = Set.new []
    remaining_urls = ['http://example.org']
    external_urls = []

    while remaining_urls.any? do
      url = remaining_urls.pop
      puts "fetching url #{url}"
      get url
      if last_response.status == 302
        follow_redirect!
      end
      assert last_response.ok?, "#{url} returns status code #{last_response.status}"
      visited_urls << url

      matches = last_response.body.scan(/href=["'](.+?)["']/)
      matches += last_response.body.scan(/src=["'](.+?)["']/)

      matches.each do |m|
        new_url = m[0]
        new_url = new_url.sub(/#.*/, '')

        # TODO: fix this in the app proper instead
        new_url = new_url.sub(/ /, '%20')

        next if new_url.empty?
        next if new_url.start_with?('mailto:')

        if not new_url.start_with?('http')
          new_url = 'http://example.org'
        end

        if not visited_urls.include? new_url \
          and not remaining_urls.include? new_url \
          and not external_urls.include? new_url
          if new_url.start_with?('http://example.org')
            remaining_urls << new_url
          elsif new_url.start_with?('http')
            external_urls << new_url
          end
        end
      end
    end

    puts "external urls:"
    puts external_urls
  end
end
