class ReportsController < ApplicationController

  authorize_resource

  def index
    # @recent_reports = Report.all
    @recent_reports = Report.open_reports(20)
  end

  def new
    # prepare to make a new report
    @report = Report.new()
  end

  def create

    @interval = Interval.new()
    @incident = Incident.new()
    @place = Place.new()
    @report = Report.new()

    @place.latitude = params[:report][:latitude]
    @place.longitude = params[:report][:longitude]

    @incident.description = params[:report][:description]

    @report.tags_string = params[:report][:tags_string]
    @report.creator = current_user if current_user

    # associoate
    @report.incident = @incident
    @place.associate_zone()
    @incident.place = @place
    @incident.interval = @interval
    @interval.begins_at = @report.created_at

    t = Tripod::Persistence::Transaction.new

    success = @report.save_report_and_children(transaction: t)

    if success
      t.commit
    else
      t.abort
    end

    if success
      redirect_to reports_path
    else
      render 'new'
    end

  end

  def show
    uri = "http://data.smartjourney.co.uk/id/report/#{params[:id]}"
    @report = Report.find(uri)
  end

  def update

  end

end