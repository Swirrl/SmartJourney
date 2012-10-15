class UserMailer < ActionMailer::Base

  default :from => "notifications@smartjourney.co.uk"
  default :to => "notifications@smartjourney.co.uk"

  def report_update_alert(report, recipients)
    @report = report
    Rails.logger.debug("bcc: #{recipients}")
    mail(:bcc => recipients, :subject => 'Report updated on smartjourney.co.uk')
  end

  def new_report_alert(report, recipients)
    @report = report
    Rails.logger.debug("bcc: #{recipients}")
    mail(:bcc => recipients, :subject => 'New report on smartjourney.co.uk')
  end

end