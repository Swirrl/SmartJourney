module ApplicationHelper

  def can_update_report?
    can?(:update, @report) && @report.still_open?
  end

  def get_zones
    Zone.all.sort{ |z1, z2| z1.label.downcase <=> z2.label.downcase }
  end

  def zone_chosen?(z)
    current_user.zone_uris.include?(z.uri.to_s)
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

end
