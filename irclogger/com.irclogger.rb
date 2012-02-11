%w(rubygems typhoeus json nokogiri date).each { |resource| require resource }

class Date 
  def nice_format
    self.strftime('%Y-%m-%d') 
  end
end

# Some vars we'll use throughout the script
END_DATE = Date.today - 1
START_DATE = Date.parse("2008-02-09")
root_url = "http://irclogger.com/"

puts "Start/End Date: #{START_DATE.nice_format}/#{END_DATE.nice_format}"

channels_logged = if File.exists?("channels_monitored.csv")
  puts "Already had channels monitored written to disk"
  File.read("channels_monitored.csv").split(",")
else
  puts "Grab the list of supported channels and write to disk"
  set = Nokogiri::HTML(Typhoeus::Request.get(root_url).body).xpath("//section//ul//li//a")
  channels = set[3,set.size].map { |s| s['href'].split("/")[1] }
  File.open("channels_monitored.csv","w+") do |file|
    file.write(channels.join(','))
  end
  channels
end

print "Channels monitored: #{channels_logged*' '}"

# Enumerate each day from start until today:
# * fetch log from the web and parse
# * store Date log content to file if it does not already exit
START_DATE.upto(END_DATE) do |date|
  puts date.nice_format
end