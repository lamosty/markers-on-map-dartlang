class MarkersController < ApplicationController
  def index
  end

  def create
    marker = Marker.where(:lat => params[:lat], :lng => params[:lng]).first

    city = City.find_by title: params[:city]
    if !city
      city = City.new(:title => params[:city])
      city.save
    end

    country = Country.find_by title: params[:country]
    if !country
      country = Country.new(:title => params[:country])
      country.save
    end

    params[:city] = city
    params[:country] = country

    if marker
      marker.update_attributes(params)
    else
      marker = Marker.new(params)
      marker.save
    end

    render :nothing => true
  end

  def show



    @markers = Marker.all()

    render json: {
      markers: @markers.to_json(include: {
        city: {},
        country: {}
      })
    }
  end

  def destroy
    marker = Marker.where(:lat => params[:lat], :lng => params[:lng]).first
    if marker
      marker.destroy
    end

    render :nothing => true
  end
end
