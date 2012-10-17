class ReportsController < ApplicationController

  authorize_resource

  after_filter :send_new_report_alerts, :only => [:create]
  after_filter :send_report_update_alerts, :only => [:update, :close]

  def index
    @future = params[:future] && params[:future].to_bool
    @selected_zones_only = current_user && params[:selected_zones_only] && params[:selected_zones_only].to_bool
    @tags_string = params[:tags] if params[:tags].present? # not blank.

    @tags = @tags_string.split(",").map {|t| t.strip } if @tags_string

    if @future
      @reports = Report.future_reports(20)
    else
      @reports = Report.open_reports(20)
    end

    #TODO: can we do these in the sparql?
    @reports.select! { |r| current_user.in_zones?(r.zone) } if @selected_zones_only
    @reports.select! { |r| (r.tags & @tags).any? } if @tags # return where there's at least one match
  end

  def new
    # prepare to make a new report
    @report = Report.new()
  end

  def create
    @report = Report.new()

    if params[:report]
      @report.latitude = params[:report][:latitude]
      @report.longitude = params[:report][:longitude]
      @report.description = params[:report][:description]
      @report.tags_string = params[:report][:tags_string]
      @report.creator = current_user if current_user

      if can? :create, :planned_incident
        @report.incident_begins_at = params[:report][:incident_begins_at] if params[:report][:incident_begins_at].present?
        @report.incident_begins_at = params[:report][:incident_ends_at] if params[:report][:incident_ends_at].present?
      end
    end

    @success = @report.save

    if @success
      flash[:notice] = 'successfully created report'
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

    if params[:report]
      @report.latitude = params[:report][:latitude]
      @report.longitude = params[:report][:longitude]
      @report.description = params[:report][:description]
      @report.tags_string = params[:report][:tags_string]

      if can? :update, :planned_incident
        @report.incident_begins_at = params[:report][:incident_begins_at].present? ? params[:report][:incident_begins_at] : Time.now
        @report.incident_begins_at = params[:report][:incident_ends_at] if params[:report][:incident_ends_at].present?
      end
    end

    @success = @report.save

    if @success
      flash[:notice] = 'successfully updated report'
      redirect_to report_path(@report)
    else
      render 'show'
    end
  end

  # PUT /reports/:id/close
  def close
    get_report

    authorize! :update, @report # this is a non-restful action, so manually auth.

    @report.close! # this shouldn't ever fail. If it does it's an exception.

    flash[:notice] = 'successfully closed report'
    redirect_to report_path(@report)
  end

  private

  def send_new_report_alerts
    UserMailer.new_report_alert(@report, current_user).deliver if @success
  end

  def send_report_update_alerts
    UserMailer.report_update_alert(@report, current_user).deliver if @success
  end

  def get_report
    uri = "http://data.smartjourney.co.uk/id/report/#{params[:id]}"
    @report = Report.find(uri)
  end

end