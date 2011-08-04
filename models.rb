Dir['./models/*.rb'].each do |model|
  require model
end

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db("dearings")
end
