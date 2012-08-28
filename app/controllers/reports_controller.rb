class ReportsController < ApplicationController

  def index
    @reports = Report.all
  end

  def new
    # prepare to make a new report
    @report = Report.new()
  end

  def create
    # save a new report.
    @report = Report.new()

    @report.description = params[:report][:description]
    @report.datetime = params[:report][:datetime]
    @report.latitude = params[:report][:latitude]
    @report.longitude = params[:report][:longitude]

    if @report.save
      redirect_to reports_path
    else
      render 'new'
    end
  end

end