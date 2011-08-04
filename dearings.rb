require 'sinatra'
require './models'

# Capture some data for stats
def capture_user_info(request, url_id)
  ci = ClickInstance.new
  ci.referer = request.referer
  ci.accept = request.env["HTTP_ACCEPT"]
  ci.accept_encoding = request.env["HTTP_ACCEPT_ENCODING"]
  ci.accept_charset = request.env["HTTP_ACCEPT_CHARSET"]
  ci.accept_language = request.env["HTTP_ACCEPT_LANGUAGE"]
  ci.from = request.env["HTTP_X_FORWARDED_FOR"] || request.ip
  ci.via = request.env["HTTP_VIA"]
  ci.request_uri = request.url
  ci.user_agent = request.user_agent
  ci.http_version = request.env["HTTP_VERSION"]
  ci.shortened_url_id = url_id
  ci.save
end

def not_valid
  status 400
  "Invalid url"
end

get '/:id' do
  begin
    if params[:id] =~ /[0-9a-z]/
      # to_i(36) will use a radix of 36 when parsing a string
      url = ShortenedUrl.find_by_param_id(params[:id]).first
      if url.nil?
        if ShortenedUrl.where(:slug => params[:id]).exists?
          url = ShortenedUrl.where(:slug => params[:id]).first
        else
          status 404
          return "URL not found"
        end
      end
      url.inc(:clicks, 1)
      capture_user_info(request, url.id)
      redirect url.long_url
    else
      not_valid
    end
  # rescue
  #   not_valid
  end
end

# Where the link gets added
# Secure this path on your webserver
post '/url/new' do
  su = ShortenedUrl.new
  su.long_url = params[:url]
  last = ShortenedUrl.last
  if last.nil?
    su.int_id = 1
  else
    su.int_id = last.int_id + 1
  end
  su.slug = params[:slug] if params[:slug]
  su.save!
  "url=#{su.to_url(request)}"
end
