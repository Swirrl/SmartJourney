module ApplicationHelper

  def can_update_report?
    can? :update, @report
  end

  def get_zones
    Zone.all
  end

  def zone_chosen?(z)
    current_user.zone_uris.include?(z.uri.to_s)
  end

end
