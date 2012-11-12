class ReportsController < ApplicationController

  before_filter :set_intro_colour
  before_filter :get_existing_report, :only => [:show, :update, :close, :comment]
  before_filter :instantiate_new_report, :only => [:new, :create]

  load_and_authorize_resource # this will only load a resource if there isn't one in @report already.
  skip_load_and_authorize_resource :only => [:close, :comment] # do this manually.

  after_filter :send_new_report_alerts, :only => [:create]
  after_filter :send_report_update_alerts, :only => [:update, :close]

  #caches_action :index, :cache_path => Proc.new {|c| c.params} # to make sure we keep the filters.
  #caches_action :show

  def index
    @intro_colour = "blue" # override the orange
    @future = params[:future] && params[:future].to_bool
    @selected_zones_only = current_user && params[:selected_zones_only] && params[:selected_zones_only].to_bool
    @tags_string = params[:tags] if params[:tags].present? # not blank.

    @tags = @tags_string.split(",").map {|t| t.strip.downcase }.uniq if @tags_string

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
    @reporting = true
  end

  def create
    @reporting = true
    if params[:report]
      @report.latitude = params[:report][:latitude]
      @report.longitude = params[:report][:longitude]
      @report.description = params[:report][:description]
      @report.tags_string = params[:report][:tags_string]
      @report.creator = current_user if current_user

      if can? :create, :planned_incident
        @report.incident_begins_at = params[:report][:incident_begins_at] if params[:report][:incident_begins_at].present?
        @report.incident_ends_at = params[:report][:incident_ends_at] if params[:report][:incident_ends_at].present?
      end
    end

    @success = @report.save

    if @success
      flash[:notice] = 'successfully created report'
      redirect_to reports_url
    else
      render 'new'
    end

  end

  def show
    @reporting = true
    @comment = Comment.new
    @comments = @report.comments
  end

  def update
    @reporting = true
    if params[:report]
      @report.latitude = params[:report][:latitude]
      @report.longitude = params[:report][:longitude]
      @report.description = params[:report][:description]
      @report.tags_string = params[:report][:tags_string]

      if can? :update, :planned_incident
        @report.incident_begins_at = params[:report][:incident_begins_at].present? ? params[:report][:incident_begins_at] : Time.now
        @report.incident_ends_at = params[:report][:incident_ends_at] if params[:report][:incident_ends_at].present?
      end
    end

    @success = @report.save

    if @success
      flash[:notice] = 'successfully updated report'
      redirect_to report_url(@report)
    else
      render 'show'
    end
  end

  # PUT /reports/:id/close
  def close
    authorize! :update, @report # this is a non-restful action, so manually auth.

    @report.close! # this shouldn't ever fail. If it does it's an exception.

    flash[:notice] = 'successfully closed report'
    redirect_to report_url(@report)
  end

  private

  #TODO: change to delayed job?
  # note: Would need to pass in a hash of strings, as @report can't be serialized as yaml by delayed_job!
  def send_new_report_alerts
    if @success
      @report.new_report_alert_recipients(current_user).each do |e|
        UserMailer.new_report_alert(@report, current_user, e).deliver
      end
    end
  end

  def send_report_update_alerts
    if @success
      @report.report_update_alert_recipients(current_user).each do |e|
        UserMailer.report_update_alert(@report, current_user, e).deliver
      end
    end
  end

  def get_existing_report
    uri = "http://data.smartjourney.co.uk/id/report/#{params[:id]}"
    @report = Report.find(uri)
  end

  def instantiate_new_report
    @report = Report.new()
  end

  def set_intro_colour
   @intro_colour = "orange"
  end

end