class City < ActiveRecord::Base
  attr_accessible :title, :id

  has_many :markers
end
