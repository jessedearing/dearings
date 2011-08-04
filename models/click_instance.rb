require 'mongoid'

class ClickInstance
  include Mongoid::Document

  belongs_to :shortened_url

  field :referer
  field :accept
  field :accept_encoding
  field :accept_charset
  field :accept_language
  field :from
  field :via
  field :user_agent
  field :request_uri
  field :http_version
end
