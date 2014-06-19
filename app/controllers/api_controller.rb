class ApiController < ApplicationController
  def markers
    logger.debug params

    @markers = Marker.all

    if !params[:id].nil?
      @markers = @markers.where(:id => params[:id])
      logger.info "ID was specified."
    end

    if !params[:heading].nil?
      @markers = @markers.where(:heading => params[:heading])
      logger.info "Heading was specified."
    end

    if !params[:body].nil?
      @markers = @markers.where(:body => params[:body])
      logger.info "Body was specified."
    end

    if !params[:marker_type].nil?
      @markers = @markers.where(:markerType => params[:marker_type])
      logger.info "Marker type was specified."
    end

    if !params[:locality].nil?
      locality = params[:locality].split(',')
      @markers = @markers.where('"city_id" IN (?) OR "country_id" IN (?)',
        City.where("title IN (?)", locality).pluck(:id),
        Country.where("title IN (?)", locality).pluck(:id)
      )
      logger.info "Locality (city or country) was specified."
    end

    render json: {
      markers: @markers.to_json(include: {
          city: {},
          country: {}
      })
    }

  end

  def new_markers
    logger.debug params

    new_markers_array = []

    if params[:markers].kind_of?(Array)
      params[:markers].each do |marker|
        new_markers_array << handle_marker(marker)
      end
    end

    render json: {
        :status => "OK",
        :new_markers_id => new_markers_array
    }
  end

  def handle_marker(marker)
    @marker = Marker.where(:lat => marker[:lat], :lng => marker[:lng]).first

    city = City.find_by title: marker[:city]
    if !city
      city = City.new(:title => marker[:city])
      city.save
    end

    country = Country.find_by title: marker[:country]
    if !country
      country = Country.new(:title => marker[:country])
      country.save
    end

    marker[:city] = city
    marker[:country] = country

    if @marker
      @marker.update_attributes(marker)
    else
      @marker = Marker.new(marker)
      @marker.save
    end

    return @marker.id
  end
end
