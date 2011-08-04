require 'mongoid'

class ShortenedUrl
  include Mongoid::Document

  has_many :click_instances

  field :int_id
  field :long_url
  field :clicks, :type => Integer, :default => 0
  field :slug

  index :int_id
  index :slug

  def to_url(request)
    "#{request.scheme}://#{request.host}/#{self.param}"
  end

  def self.find_by_param_id(int_id)
    where(:int_id => int_id.to_i(36))
  end

  def param
    self.slug || self.int_id.to_s(36)
  end
end
