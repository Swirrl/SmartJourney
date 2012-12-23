class ReportAlertsJob < Struct.new(:report_uri, :emails, :user_screen_name, :action)
  def perform

    if action == :new

      Rails.logger.info("*** Sending new report emails with delayed job")
      emails.each do |email|
        UserMailer.new_report_alert(report_uri, email).deliver # notice no screen name
      end

    elsif action == :update

      Rails.logger.info("*** Sending report update emails with delayed job")
      emails.each do |email|
        UserMailer.report_update_alert(report_uri, email, user_screen_name).deliver
      end

    elsif action == :close

      Rails.logger.info("*** Sending close report emails with delayed job")
      emails.each do |email|
        UserMailer.closed_report_alert(report_uri, email, user_screen_name).deliver
      end

    end
  end
end


