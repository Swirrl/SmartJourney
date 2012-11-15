class Zone

  include Tripod::Resource

  def self.rdf_type
    RDF::URI("http://data.smartjourney.co.uk/def/Zone")
  end

  def self.graph_uri
    RDF::URI("http://data.smartjourney.co.uk/graph/zones")
  end

  field :label, RDF::RDFS.label
  field :rdf_type, RDF.type
  field :notation, RDF::URI.new('http://www.w3.org/2004/02/skos/core#notation')


  #######################
  # NOTE:
  # The zones will be predefined in the database, do don't need a initializer or validations
  #######################

  def self.all
    self.where("
      SELECT ?uri (<#{Zone.graph_uri}> AS ?graph)
      WHERE {
        GRAPH <#{Zone.graph_uri}> {
          ?uri a <#{Zone.rdf_type.to_s}> .
        }
      }"
    )
  end

  # get an array of this zone's reports.
  def reports
    #TODO - get all the reports where it's incident's place is in the zone.
  end

  def extent_json_url
    "http://data.smartjourney.co.uk/zone_boundaries/#{notation}.json"
  end

  def region
    uri.to_s.split('/')[-2]
  end

  def zoneslug
    uri.to_s.split('/').last
  end

  def slug
    region + '_' + zoneslug
  end

  def self.uri_from_slug(the_slug)
    Rails.logger.debug('in uri from slug')
    Rails.logger.debug("the slug: #{the_slug}")
    "http://data.smartjourney.co.uk/id/zone/" + the_slug.split('_').first + '/' + the_slug.split('_').last
  end

  def as_json(options =nil)
    {
      :slug => slug
    }
  end


  def self.zone_for_lat_long(lat, long)
    Rails.logger.debug( "in zone for lat long #{lat}, #{long}" )
    # loop over files
    filelist = Dir.glob("#{Rails.root}/public/zone_boundaries/*.json")
    zoneslug = nil
    filelist.each do |f|
      unless (f =~ /all_boundaries/)
        file = File.new(f)
        zone = JSON.parse(file.read)
        if Polygon.point_in_zone(long.to_f,lat.to_f,zone)
          zoneslug = f.split('/').last.gsub(/\.json/,'')
          file.close
          break  # assume only one polygon contains the point
        end
        file.close
      end
    end

    region = nil
    uri = nil

    if zoneslug
      if zoneslug[0,9] == "aberdeen-"
        region = "aberdeen-city/"
      else
        region = "aberdeenshire/"
      end
      uri = "http://data.smartjourney.co.uk/id/zone/" + region + zoneslug
    end

    Rails.logger.debug "Zone URI #{uri}"

    Zone.find(uri) rescue nil # if it's not there, return nil.
  end

end