class CommentsController < ApplicationController

  before_filter :get_existing_report, :set_intro_colour, :set_reporting

  before_filter :get_comment, :only => [:destroy]

  load_and_authorize_resource

  # add a comment.
  # POST /reports/:id/comments
  def create

    t = Tripod::Persistence::Transaction.new

    @comment = Comment.new
    @comment.content = params[:content]
    @comment.creator = current_user
    comment_success = @comment.save(:transaction => t)

    if comment_success
      @report.add_comment(@comment)
      if params[:commit] == "Comment And Close" && can?(:update, @report)
        @report.close!
        @closed = true
      end
      report_success = @report.save(:transaction => t)
    end

    @success = comment_success && report_success

    if @success
      t.commit
      flash[:notice] = 'comment added'
      flash[:notice] += ' and report closed' if @closed

      if @report.creator && @report.creator.receive_email_comments && @current_user.uri != @report.creator.uri
        # this queues it with delayed job.
        UserMailer.delay.new_comment_alert(@report.uri.to_s, @comment.uri.to_s, @report.creator.email)
      end

      redirect_to report_url(@report)
    else
      t.abort
      flash.now[:alert] = 'Something went wrong adding your comment.'
      @comments = @report.comments
      render 'reports/show'
    end

  end

  def destroy
    @comment.destroy
    flash[:notice] = 'comment deleted'
    redirect_to report_url(@report)
  end

  private

  def get_comment
    uri = "http://data.smartjourney.co.uk/id/comment/#{params[:id]}"
    @comment = Comment.find(uri)
  end

  def get_existing_report
    uri = "http://data.smartjourney.co.uk/id/report/#{params[:report_id]}"
    @report = Report.find(uri)
  end

  def set_intro_colour
    @intro_colour = "orange"
  end

  def set_reporting
    @reporting=true #prevents report it btn showing in footer
  end

end
