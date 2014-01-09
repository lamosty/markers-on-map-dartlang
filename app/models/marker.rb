class Marker < ActiveRecord::Base
  attr_accessible :title, :lat, :lng, :street,
                  :zip, :city

  has_one :city
  has_one :country
end
