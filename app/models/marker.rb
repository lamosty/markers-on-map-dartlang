class Marker < ActiveRecord::Base
  attr_accessible :heading, :body, :markerType,
                  :lat, :lng, :street,
                  :zip, :city, :country

  belongs_to :city
  belongs_to :country

end
