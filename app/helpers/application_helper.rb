module ApplicationHelper

  def can_update_report?
    can? :update, @report
  end

end
