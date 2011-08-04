require 'mongoid'

class ClickInstance
  include Mongoid::Document

  belongs_to :shortened_url

  field :data, :type => Hash
end
