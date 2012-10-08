class ReportsController < ApplicationController

  authorize_resource

  def index
    # @recent_reports = Report.all
    @recent_reports = Report.recent_open_reports(Time.now, 60*60*24)
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
    @report.tags_string = params[:report][:tags_string]
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

  def show
    uri = "http://#{PublishMyData.local_domain}/id/report/#{params[:id]}"
    @report = Report.find(uri)
  end

  def update

  end

end