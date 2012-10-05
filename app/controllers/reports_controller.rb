class ReportsController < ApplicationController

  load_and_authorize_resource

  def index
    @recent_reports = Report.all
    # Report.recent_open_reports(Time.now, 60*60*24)
  end

  def new
    # prepare to make a new report
    @report = Report.new()
  end

  def create

    Rails.logger.debug( "About to make new" )
    @report = Report.new()
    @report.description = params[:report][:description]
    @report.latitude = params[:report][:latitude]
    @report.longitude = params[:report][:longitude]
    @report.report_type = ReportType.new(params[:report][:report_type])
    @report.creator = current_user if current_user

    # TODO: make these be callbacks?
    @report.created_at = Time.now
    @report.label = @report.description[0,100]

    @report.associate_zone()

    Rails.logger.debug( "About to save" )

    Rails.logger.debug @report.repository.dump(:ntriples)

    if @report.save
      redirect_to reports_path
    else
      render 'new'
    end
  end

end