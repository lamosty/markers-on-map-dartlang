class City < ActiveRecord::Base
  attr_accessible :title

  has_many :markers
end
