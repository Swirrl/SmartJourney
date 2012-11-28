class ReportsController < ApplicationController

  before_filter :set_intro_colour
  before_filter :get_existing_report, :only => [:show, :update, :close, :comment]
  before_filter :instantiate_new_report, :only => [:new, :create]

  load_and_authorize_resource # this will only load a resource if there isn't one in @report already.
  skip_load_and_authorize_resource :only => [:close, :comment, :tags] # do this manually.

  after_filter :send_new_report_alerts, :only => [:create]
  after_filter :send_report_update_alerts, :only => [:update, :close]

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

  def tags
    # expect param term to filter
    term = params[:term] || ""

    query = "SELECT DISTINCT ?tag
    WHERE {
      ?report a <http://data.smartjourney.co.uk/def/Report> .
      ?report <http://data.smartjourney.co.uk/def/tag> ?tag .
      FILTER regex(?tag, \"^" + term + "\", \"i\")
    }
    ORDER BY ASC(?tag)
    "
    results = Tripod::SparqlClient::Query.select(query).collect{ |r| r["tag"]["value"] }
    # add in the curated ones.
    results += Report.curated_tags.select { |t| t.start_with?(term) }
    results = results.uniq.sort
    render :json => results
  end

  def create

    respond_to do |format|

      # POST /reports/
      format.html do
        @reporting = true # hide report it btn
        populate_report_from_params(params[:report], true, :create) if params[:report]
        @success = @report.save

        if @success
          flash[:notice] = 'successfully created report'
          redirect_to reports_url
        else
          render 'new'
        end
      end

      # POST /reports.json
      # POST /reports (with accept header)
      format.json do
        populate_report_from_params(params[:report], true, :create) if params[:report]
        @success = @report.save
        if @success
          render :json => @report, :status => :created
        else
          render :json => @report.errors, :status => :bad_request
        end
      end
    end

  end

  def show
    @reporting = true
    @comment = Comment.new
    @comments = @report.comments
  end

  def update
    respond_to do |format|
      format.html do
        @reporting = true
        populate_report_from_params(params[:report], false, :update) if params[:report]
        @success = @report.save

        if @success
          flash[:notice] = 'successfully updated report'
          redirect_to report_url(@report)
        else
          render 'show'
        end
      end

      format.json do
        populate_report_from_params(params[:report], false, :update) if params[:report]
        @success = @report.save
        if @success
          head :ok
        else
          render :json => @report.errors, :status => :bad_request
        end
      end
    end
  end

  # PUT /reports/:id/close
  def close

    authorize! :update, @report # this is a non-restful action, so manually auth.

    @report.close! # this shouldn't ever fail. If it does it's an exception.

    respond_to do |format|

      format.html do
        flash[:notice] = 'successfully closed report'
        redirect_to report_url(@report)
      end

      format.json do
        head :ok
      end
    end
  end

  private

  def populate_report_from_params(report_params, set_creator = false, action = :create)
    @report.latitude = params[:report][:latitude]
    @report.longitude = params[:report][:longitude]
    @report.description = params[:report][:description]
    @report.tags_string = params[:report][:tags_string]
    @report.creator = current_user if current_user && set_creator

    if can? action, :planned_incident
      @report.incident_begins_at = params[:report][:incident_begins_at].present? ? params[:report][:incident_begins_at] : Time.now
      @report.incident_ends_at = params[:report][:incident_ends_at] if params[:report][:incident_ends_at].present?
    end
  end

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