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

    # associate
    @report.incident = @incident
    @place.associate_zone()
    @incident.place = @place
    @incident.interval = @interval

    t = Tripod::Persistence::Transaction.new

    success = @report.save_report_and_children(transaction: t)

    if success
      t.commit
    else
      t.abort
    end

    if success
      flash[:notice] = 'Succesfully created report'
      redirect_to reports_path
    else
      render 'new'
    end

  end

  def show
    get_report
  end

  def update
    get_report

    @incident = @report.incident
    @place = @incident.place

    @place.latitude = params[:report][:latitude]
    @place.longitude = params[:report][:longitude]

    @place.associate_zone()

    @report.tags_string = params[:report][:tags_string]

    t = Tripod::Persistence::Transaction.new

    success = @report.save_report_and_children(transaction: t)

    if success
      t.commit
    else
      t.abort
    end

    if success
      flash[:notice] = 'Succesfully updated report'
      redirect_to report_path(@report)
    else
      render 'show'
    end
  end

  # PUT /reports/:id/close
  def close
    get_report

    authorize! :update, @report # this is a non-restful action, so manually auth.

    # todo: Set the end time of the incident.
  end

  private

  def get_report
    uri = "http://data.smartjourney.co.uk/id/report/#{params[:id]}"
    @report = Report.find(uri)
  end

end