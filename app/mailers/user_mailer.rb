class UserMailer < ActionMailer::Base

  default :from => "donotreply@smartjourney.co.uk"
  default :bcc => "smartjourney@swirrl.com"

  def new_report_alert(report_uri, recipient_email)
    @report = Report.find(report_uri)
    mail(:to => recipient_email, :subject => 'New report on smartjourney.co.uk')
  end

  def report_update_alert(report_uri, recipient_email, user_screen_name)
    @report = Report.find(report_uri)
    @user_screen_name = user_screen_name
    mail(:to => recipient_email, :subject => 'Report updated on smartjourney.co.uk')
  end

  def closed_report_alert(report_uri, recipient_email, user_screen_name)
    @report = Report.find(report_uri)
    @user_screen_name = user_screen_name
    mail(:to => recipient_email, :subject => 'Report closed on smartjourney.co.uk')
  end

  def new_comment_alert(report_uri, comment_uri, recipient_email)
    @report = Report.find(report_uri)
    @comment = Comment.find(comment_uri)
    mail(:to => recipient_email, :subject => 'Someone commented on one of your SmartJourney reports')
  end

end