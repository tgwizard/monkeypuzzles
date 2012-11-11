
desc "This task should be called regularly to keep the site alive"
task :keep_alive => :environment do
  puts "Attempting to keep the site alive..."
  uri = URI.parse('http://monkeypuzzles.org')
  Net::HTTP.get(uri)
  puts "Site kept alive!"
end
