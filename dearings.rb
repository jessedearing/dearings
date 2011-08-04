require 'sinatra'
require 'awesome_print'
Dir['./models/*.rb'].each do |model|
  require model
end

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db("dearings")
end

def capture_user_info(request, url_id)
  ci = ClickInstance.new
  ci.referer = request.referer
  ci.accept = request.env["HTTP_ACCEPT"]
  ci.accept_encoding = request.env["HTTP_ACCEPT_ENCODING"]
  ci.accept_charset = request.env["HTTP_ACCEPT_CHARSET"]
  ci.accept_language = request.env["HTTP_ACCEPT_LANGUAGE"]
  ci.from = request.ip
  ci.via = request.env["HTTP_VIA"]
  ci.request_uri = request.url
  ci.user_agent = request.user_agent
  ci.http_version = request.env["HTTP_VERSION"]
  ci.shortened_url_id = url_id
  ci.save
end

def gigo
  status 400
  "Invalid url"
end

get '/:id' do
  begin
    if params[:id] =~ /[0-9a-z]/
      url = ShortenedUrl.where(:int_id => params[:id].to_i(36)).first
      url.inc(:clicks, 1)
      capture_user_info(request, url.id)
      redirect url.long_url
    else
      gigo
    end
  rescue
    gigo
  end
end

post '/url/new' do
  su = ShortenedUrl.new
  su.long_url = params[:url]
  last = ShortenedUrl.last
  if last.nil?
    su.int_id = 1
  else
    su.int_id = last.int_id + 1
  end
  su.save!
end
