%w(rubygems typhoeus json nokogiri date).each { |resource| require resource }

DIR_PATH = "irclogger/"

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
START_DATE = Date.parse("2010-10-17")
#START_DATE = Date.parse("2008-08-10")
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
Dir.mkdir(DIR_PATH) unless File.directory?(DIR_PATH)
channels_logged.each do |ch|
  dir = "#{DIR_PATH}#{ch}"
  next if File.directory?(dir)
  puts "Creating #{dir}"
  Dir.mkdir(dir)
end

# Enumerate each day from start until today:
# * fetch log from the web and parse
# * store Date log content to file if it does not already exit
START_DATE.upto(END_DATE) do |date|
  channels_logged.each do |channel|
    store_path = "#{DIR_PATH}#{channel}/#{date.nice_format}.txt"
    next if File.exists?(store_path)
    
    channel_url = "#{ROOT_URL}.#{channel}/#{date.nice_format}"
    log_text = grab_page(channel_url).body
    unless log_text.empty?
      puts "Grabbing #{channel_url} and storing to #{store_path}"
      puts log_text.inspect
      File.open(store_path,"w+") { |f| f.write(log_text) }
    else
      puts "Grabbing #{channel_url} however, nothing to grab"
    end
    sleep(0.5)
  end
end