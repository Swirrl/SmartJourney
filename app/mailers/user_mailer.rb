class UserMailer < ActionMailer::Base

  default :from => "donotreply@smartjourney.co.uk"
  default :bcc => "smartjourney@swirrl.com"

  def report_update_alert(report, current_user, recipient_email)
    @report = report
    mail(:to => recipient_email, :subject => 'Report updated on smartjourney.co.uk')
  end

  def new_report_alert(report, current_user, recipient_email)
    @report = report
    mail(:to => recipient_email, :subject => 'New report on smartjourney.co.uk')
  end

  def new_comment_alert(report, comment, current_user, recipient_email)
    @report = report
    @comment = comment
    mail(:to => recipient_email, :subject => 'Someone commented on one of your SmartJourney reports')
  end

end