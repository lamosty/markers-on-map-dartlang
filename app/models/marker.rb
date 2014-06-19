class Marker < ActiveRecord::Base
  attr_accessible :heading, :body, :markerType,
                  :lat, :lng, :street,
                  :zip, :city_id, :country_id

  belongs_to :city
  belongs_to :country

end
