module ApplicationHelper

  def can_update_report?
    can? :update, @report
  end

  def get_zones
    Zone.all.sort{ |z1, z2| z1.label.downcase <=> z2.label.downcase }
  end

  def zone_chosen?(z)
    current_user.zone_uris.include?(z.uri.to_s)
  end

end
