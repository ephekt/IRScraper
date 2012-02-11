%w(rubygems typhoeus json nokogiri date).each { |resource| require resource }

class Date 
  def nice_format
    self.strftime('%Y-%m-%d') 
  end
end

def grab_page url
  raise unless url
  Typhoeus::Request.get(url)
end

# Some vars we'll use throughout the script
END_DATE = Date.today - 1
START_DATE = Date.parse("2008-02-09")
ROOT_URL = "http://irclogger.com/"

puts "Start/End Date: #{START_DATE.nice_format}/#{END_DATE.nice_format}"

channels_logged = if File.exists?("channels_monitored.csv")
  puts "Already had channels monitored written to disk"
  File.read("channels_monitored.csv").split(",")
else
  puts "Grab the list of supported channels and write to disk"
  set = Nokogiri::HTML(grab_page(ROOT_URL).body).xpath("//section//ul//li//a")
  channels = set[3,set.size].map { |s| s['href'].split("/")[1].tr(".","").gsub(" ","_") }
  File.open("channels_monitored.csv","w+") do |file|
    file.write(channels.join(','))
  end
  channels
end

puts "Channels monitored: #{channels_logged*' '}"

# Create directories
channels_logged.each do |ch|
  puts "Creating #{ch}"
  Dir.mkdir(ch) unless File.directory?(ch)
end

# Enumerate each day from start until today:
# * fetch log from the web and parse
# * store Date log content to file if it does not already exit
START_DATE.upto(END_DATE) do |date|
  channels_logged.each do |channel|
    next if File.exists?("#{channel}/#{date.nice_format}")
    
    channel_url = "#{ROOT_URL}#{channel}/#{date.nice_format}"
    store_path= "#{channel}/#{date.nice_format}"
    puts "Grabbing #{channel_url} and storing to #{store_path}"
    File.open(store_path,"w+") do |f|
      f.write(grab_page(channel_url).body)
    end
  end
  exit
end