require 'mongoid'

class ShortenedUrl
  include Mongoid::Document

  has_many :click_instances

  field :int_id
  field :long_url
  field :clicks, :type => Integer, :default => 0
end
