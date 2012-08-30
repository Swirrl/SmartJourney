class ReportsController < ApplicationController

  load_and_authorize_resource

  def index
    Rails.logger.debug "***CURRENT USER***"
    Rails.logger.debug current_user
    @reports = Report.all
  end

  def new
    # prepare to make a new report
    @report = Report.new()
    @report.datetime = DateTime.now
  end

  def create
    # save a new report.
    @report = Report.new()

    Rails.logger.debug params[:report]

    @report.description = params[:report][:description]
    @report.datetime = params[:report][:datetime]
    @report.latitude = params[:report][:latitude]
    @report.longitude = params[:report][:longitude]
    @report.report_type = ReportType.new(params[:report][:report_type_uri])
    @report.reporter = current_user
    @report.associate_zone()

    Rails.logger.debug @report.datetime

    if @report.save
      redirect_to reports_path
    else
      render 'new'
    end
  end

end