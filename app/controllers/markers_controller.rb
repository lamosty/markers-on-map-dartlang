require 'json'

class MarkersController < ApplicationController
  def index
    cities = City.all()
    countries = Country.all()

    @locality = cities + countries
    @types = Marker.uniq.pluck(:markerType)
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
    locality = params[:locality]
    type = params[:type]


    @markers = Marker.all

    if !locality.nil?
      # @markers = @markers.where('city=? OR country=?', 'Bratislava', 'Slovakia')
      locality = locality[1..-2].split(', ')
      if !locality.empty?
        @markers = @markers.where('"city_id" IN (?) OR "country_id" IN (?)',
          City.where("title IN (?)", locality).pluck(:id),
          Country.where("title IN (?)", locality).pluck(:id)
        )
      end
    end

    if !type.nil?
      type = type[1..-2].split(', ')
      if !type.empty?
        @markers = @markers.where('"markerType" IN (?)', type)
      end
      # @markers = @markers.where('markerType=?', type)
    end

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

      otherMarkersCityCount = Marker.where(:city_id => marker.city).count
      if otherMarkersCityCount == 0
        marker.city.destroy
      end

      otherMarkersCountryCount = Marker.where(:country_id => marker.country).count
      if otherMarkersCountryCount == 0
        marker.country.destroy
      end
    end

    render :nothing => true
  end
end
