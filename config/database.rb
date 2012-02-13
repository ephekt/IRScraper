MongoMapper.connection = Mongo::Connection.new('localhost', nil, :logger => logger)

case Padrino.env
  when :development then MongoMapper.database = 'ir_scraper_development'
  when :production  then MongoMapper.database = 'ir_scraper_production'
  when :test        then MongoMapper.database = 'ir_scraper_test'
end
