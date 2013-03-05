module ApplicationHelper

  def can_update_report?
    can?(:update, @report) && @report.still_open?
  end

  def get_zones
    Zone.all.sort{ |z1, z2| z1.label.downcase <=> z2.label.downcase }
  end

  def zone_chosen?(z)
    current_user.zone_chosen?(z)
  end

  def tag_link(tag)
    opts = {:tags => tag}
    opts.merge!(:future => params[:future]) if params[:future]
    opts.merge!(:selected_zones_only => params[:selected_zones_only]) if params[:selected_zones_only]
    link_to tag, reports_path(opts)
  end

  def report_status_icon(status)
    image_tag "icon-#{status.downcase}.png"
  end

  def get_popular_tags(limit=10)

    query = "SELECT (COUNT(*) as ?count) ?tag
    WHERE {
      ?report a <http://data.smartjourney.co.uk/def/Report> .
      ?report <http://data.smartjourney.co.uk/def/tag> ?tag .
    }
    GROUP BY ?tag
    ORDER BY DESC(?count)
    LIMIT #{limit}
    "
    results = Tripod::SparqlClient::Query.select(query).collect{ |r| r["tag"]["value"] if r["tag"] }.select { |r| r.present? }
    results.insert(0, *Report.curated_tags).uniq.first(limit)
  end

  def intro_marker(tags)
    # Defaults
    img = 'default'
    klass = 'triangle'

    if (tags & ['road closed']).any?
      img = 'closed'
      klass = 'rectangle'

    elsif (tags & ['roadworks']).any?
      img = 'roadworks'

    elsif (tags & ['accident']).any?
      img = 'accident'
      klass = 'accident'

    elsif (tags & ['flood', 'surface water']).any?
      img = 'flood'

    elsif (tags & ['ice', 'snow']).any?
      img = 'ice'

    elsif (tags & ['traffic jam', 'slow']).any?
      img = 'traffic'

    elsif (tags & ['pothole', 'potholes']).any?
      img = 'pothole'
    end

    content_tag :div, image_tag("marker-#{img}-big.png"), :class => "#{klass} marker"
  end

end
