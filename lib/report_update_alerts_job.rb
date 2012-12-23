class ReportUpdateAlertsJob < Struct.new(:report_uri, :emails)
  def perform
    Rails.logger.info("Sending report update emails with delayed job")
    emails.each do |email|
      UserMailer.report_update_alert(report_uri, email).deliver
    end
  end
end