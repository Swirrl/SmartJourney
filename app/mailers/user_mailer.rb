class UserMailer < ActionMailer::Base

  default :from => "notifications@smartjourney.co.uk"
  default :to => "notifications@smartjourney.co.uk"

  def report_update_alert(report, current_user)
    @report = report
    recipients = report.report_update_recipients(current_user)
    Rails.logger.debug("UPDATE ALERT RECIPIENTS")
    Rails.logger.debug(recipients)
    mail(:bcc => recipients, :subject => 'Report updated on smartjourney.co.uk')
  end

  def new_report_alert(report, current_user)
    @report = report
    recipients = report.new_report_recipients(current_user)
    Rails.logger.debug("NEW REPORT ALERT RECIPIENTS")
    Rails.logger.debug(recipients)
    mail(:bcc => recipients, :subject => 'New report on smartjourney.co.uk')
  end

end