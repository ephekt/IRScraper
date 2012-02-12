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

latest_log_timestamp = []

Dir.mkdir(DIR_PATH) unless File.directory?(DIR_PATH)
channels_logged.each do |ch|
  dir = "#{DIR_PATH}#{ch}"
  if File.directory?(dir)
    latest_log_timestamp << `ls '#{dir}'| tail -n1`
    next
  else
    puts "Creating #{dir}"
    Dir.mkdir(dir)
  end
end

# -------
# Start Date -> Yesterday
# End Date -> Find latest log captured and go from there
# -------
END_DATE = Date.today - 1
START_DATE = Date.parse latest_log_timestamp.sort.last.split('.').first
ROOT_URL = "http://irclogger.com/"

puts "Start/End Date: #{START_DATE.nice_format}/#{END_DATE.nice_format}"


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