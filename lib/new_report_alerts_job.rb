class NewReportAlertsJob < Struct.new(:report_uri, :emails)
  def perform
    Rails.logger.info("Sending new report emails with delayed job")
    emails.each do |email|
      UserMailer.new_report_alert(report_uri, email).deliver
    end
  end
end


