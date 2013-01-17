class ReportAlertsJob < Struct.new(:report_uri, :email, :user_screen_name, :action)
  def perform

    if action == :new

      UserMailer.new_report_alert(report_uri, email).deliver # notice no screen name

    elsif action == :update

      UserMailer.report_update_alert(report_uri, email, user_screen_name).deliver

    elsif action == :close

      UserMailer.closed_report_alert(report_uri, email, user_screen_name).deliver

    end
  end
end


