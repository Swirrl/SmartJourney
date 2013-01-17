require 'spec_helper'

describe ReportsController do

  def valid_update_params
    r = FactoryGirl.build(:report)
    {:description => r.description, :tags_string => r.tags_string, :latitude => r.latitude, :longitude => r.longitude}
  end

  def invalid_update_params
    r = FactoryGirl.build(:invalid_report)
    {:description => r.description, :tags_string => r.tags_string, :latitude => r.latitude, :longitude => r.longitude}
  end

  shared_examples_for "index" do
    it 'should render' do
      response.should be_success
    end

    it 'should set @reports' do
      assigns(:reports).should_not be_nil
    end

    # TODO: filters
  end

  shared_examples_for "new" do
    it 'should render' do
      response.should be_success
    end

    it 'should set @report' do
      assigns(:report).should_not be_nil
      assigns(:report).new_record?.should be_true
    end
  end

  shared_examples_for "create" do

    context 'save fails' do

      before do
        r = FactoryGirl.build(:invalid_report)
        Report.should_receive(:new).and_return(r)
      end

      it 'should render new again' do
        post :create
        response.should be_success
        response.should render_template("reports/new")
      end

      it 'should not set a flash' do
        post :create
        flash[:notice].should be_nil
      end

      it 'should not send emails' do
        post :create
        Delayed::Job.should_not_receive(:enqueue)
      end

    end

    context 'save succeeds' do

      before do
        @recipients = ['email1@example.com', 'email2@example.com']
        @r = FactoryGirl.build(:report)
        @r.should_receive(:new_report_alert_recipients).and_return(@recipients)
        Report.should_receive(:new).and_return(@r)
      end

      it 'should redirect to index' do
        post :create
        response.should be_redirect
        response.should redirect_to reports_url
      end

      it 'should queue 2 emails' do
        job1 = ReportAlertsJob.new(@r.uri, @recipients[0], nil, :new)
        job2 = ReportAlertsJob.new(@r.uri, @recipients[1], nil, :new)
        Delayed::Job.should_receive(:enqueue).with(job1)
        Delayed::Job.should_receive(:enqueue).with(job2)
        post :create
      end

      it 'should set a flash message' do
        post :create
        flash[:notice].should_not be_nil
      end
    end

  end

  shared_examples_for "update_no_perms" do

    before do
      # make a report we're going to update
      @r = FactoryGirl.build(:report)
      @r.creator = User.where(:email => @user.email).first
      @r.save!

      Report.should_receive(:find).at_most(:once).with('http://data.smartjourney.co.uk/id/report/guid').and_return(@r)
    end

    it 'should redirect, with an alert' do
      put :update, :id => 'guid', :report => valid_update_params
      response.should be_redirect
      flash[:alert].should_not be_nil
    end
  end

  shared_examples_for "close_report_with_params" do

    before do
      @recipients = ['email1@example.com', 'email2@example.com']

      @r = FactoryGirl.build(:report)
      @r.creator = User.where(:email => @user.email).first
      @r.save!

      @r.should_receive(:report_update_alert_recipients).and_return(@recipients)
      Report.should_receive(:find).with('http://data.smartjourney.co.uk/id/report/guid').and_return(@r)
    end

    it 'should send 2 emails' do
      job = ReportAlertsJob.new(@r.uri, @recipients, @user.screen_name, :close)
      Delayed::Job.should_receive(:enqueue).with(job)
      put :close, :id => 'guid'
    end

  end

  shared_examples_for "close_report_no_params" do

    before do
      # make a report we're going to update
      @r = FactoryGirl.build(:report)
      @r.creator = User.where(:email => @user.email).first
      @r.save!

      Report.should_receive(:find).at_most(:once).with('http://data.smartjourney.co.uk/id/report/guid').and_return(@r)
    end

    it 'should redirect, with an alert' do
      put :close, :id => 'guid'
      response.should be_redirect
      flash[:alert].should_not be_nil
    end

  end

  shared_examples_for "update_with_perms" do

    context 'save fails' do

      before do
        @r = FactoryGirl.build(:report)
        @r.creator = User.where(:email => @user.email).first
        @r.save!

        Report.should_receive(:find).with('http://data.smartjourney.co.uk/id/report/guid').and_return(@r)
      end

      it 'should render show' do
        put :update, :id => 'guid', :report => invalid_update_params
        response.should be_success
        response.should render_template("reports/show")
      end

      it 'should not set a flash' do
        put :update, :id => 'guid', :report => invalid_update_params
        flash[:notice].should be_nil
      end

      it 'should not send emails' do
        put :update, :id => 'guid', :report => invalid_update_params
        Delayed::Job.should_not_receive(:enqueue)
      end

    end

     context 'save succeeds' do

      before do
        @recipients = ['email1@example.com', 'email2@example.com']

        @r = FactoryGirl.build(:report)
        @r.creator = User.where(:email => @user.email).first
        @r.save!

        @r.should_receive(:report_update_alert_recipients).and_return(@recipients)
        Report.should_receive(:find).with('http://data.smartjourney.co.uk/id/report/guid').and_return(@r)
      end

      it 'should redirect to show' do
        put :update, :id => 'guid', :report => valid_update_params
        response.should be_redirect
        response.should redirect_to report_url(@r)
      end

      it 'should send 2 emails' do
        job1 = ReportAlertsJob.new(@r.uri, @recipients[0], @user.screen_name, :update)
        job2 = ReportAlertsJob.new(@r.uri, @recipients[1], @user.screen_name, :update)
        Delayed::Job.should_receive(:enqueue).with(job1)
        Delayed::Job.should_receive(:enqueue).with(job2)
        put :update, :id => 'guid', :report => valid_update_params
      end

      it 'should set a flash message' do
        put :update, :id => 'guid', :report => valid_update_params
        flash[:notice].should_not be_nil
      end

    end

  end

  describe 'Get on #index' do

    context 'not signed in' do

      before do
        get :index
      end

      it_behaves_like "index"
    end

    context 'signed in as user' do

      before do
        sign_in FactoryGirl.create(:user)
        get :index
      end

      it_behaves_like "index"

    end

    context 'signed in as admin user' do

      before do
        sign_in FactoryGirl.create(:admin_user)
        get :index
      end

      it_behaves_like "index"

    end

  end

  describe 'Get on #new' do

    context 'not signed in' do

      before do
        get :new
      end

      it_behaves_like "new"
    end

    context 'signed in as user' do

      before do
        sign_in FactoryGirl.create(:user)
        get :new
      end

      it_behaves_like "new"

    end

    context 'signed in as admin user' do

      before do
        sign_in FactoryGirl.create(:admin_user)
        get :new
      end

      it_behaves_like "new"

    end

  end

  describe 'Post to #create' do

    context 'not signed in' do
      it_behaves_like "create"
    end

    context 'signed in as user' do
      before do
        sign_in FactoryGirl.create(:user)
      end

      it_behaves_like "create"
    end

    context 'signed in as admin user' do
      before do
        sign_in FactoryGirl.create(:admin_user)
      end

      it_behaves_like "create"
    end

  end

  describe "API post to #create" do

    before do
      request.env['HTTP_ACCEPT'] = 'application/json'
      request.env['CONTENT_TYPE'] = 'application/json'
      @user = FactoryGirl.create(:user)
      @admin_user = FactoryGirl.create(:admin_user)
    end

    context 'good_content' do
      before do
        r = FactoryGirl.build(:report)
        @json = { :report => {
          :description => r.description,
          :latitude => r.latitude,
          :longitude => r.longitude,
          :tags_string => 'tag1, tag2',
          :incident_begins_at => '2010-01-01 12:00',
          :incident_ends_at => '2050-01-01 12:01'
          }
        }
      end

      context 'no api key provided' do
        it 'returns bad request' do
          post :create, @json
          response.code.should == "401"
        end
      end

      context 'bad api key provided' do
        it 'returns bad request' do
          request.env['api-key'] = 'bleh'
          post :create, @json
          response.code.should == "401"
        end
      end

      context 'normal user api key provided' do

        it 'successfully creates, but ignores planned incidents' do
          request.env['api-key'] = @user.api_key
          post :create, @json
          response.code.should == "201" #created
          Report.all.last.incident_begins_at.should_not be_nil
          Time.parse(Report.all.last.incident_begins_at).should_not == Time.parse(@json[:report][:incident_begins_at])
          Report.all.last.incident_ends_at.should be_nil
        end
      end

      context 'admin api key provided' do
        it 'successfully creates, including the planned incident ' do
          request.env['api-key'] = @admin_user.api_key
          post :create, @json
          response.code.should == "201" #created
          Time.parse(Report.all.last.incident_begins_at).should == Time.parse(@json[:report][:incident_begins_at])
          Time.parse(Report.all.last.incident_ends_at).should == Time.parse(@json[:report][:incident_ends_at])
        end
      end

    end

    context 'dodgy content' do
      before do
        request.env['api-key'] = @admin_user.api_key
        r = FactoryGirl.build(:report)
        @json = { :report => {
          :description => '',
          :tags_string => ''
          }
        }
      end

      it "should 400" do
        post :create, @json
        response.code.should == "400"
      end
    end

  end

  # describe 'put to #close' do

  #   context 'not signed in' do
  #     before do
  #       @user = FactoryGirl.create(:user)
  #       # don't sign in tho.
  #     end

  #     it_behaves_like "close_report_no_params"
  #   end

  #   context 'signed in as user who created the report' do
  #     before do
  #       @user = FactoryGirl.create(:user)
  #       sign_in @user
  #     end

  #     it_behaves_like "close_report_with_params"
  #   end

  #   context 'signed in as user who did not create the report' do
  #     before do
  #       @user = FactoryGirl.create(:user)

  #       # sign in as a different user.
  #       @user2 = FactoryGirl.build(:user)
  #       @user2.screen_name = 'bobby'
  #       @user2.email = 'bob@swirrl.com'
  #       @user2.save!

  #       sign_in @user2
  #     end

  #     it_behaves_like "close_report_no_params"
  #   end

  #   context 'signed in as admin user' do
  #     before do
  #       @user = FactoryGirl.create(:admin_user)
  #       sign_in @user
  #     end

  #     it_behaves_like "close_report_with_params"
  #   end
  # end

  describe 'Put to #update' do

    context 'not signed in' do
      before do
        @user = FactoryGirl.create(:user)
        # don't sign in tho.
      end

      it_behaves_like "update_no_perms"
    end

    context 'signed in as user who created the report' do
      before do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end

      it_behaves_like "update_with_perms"
    end

    context 'signed in as user who did not create the report' do
      before do
        @user = FactoryGirl.create(:user)

        # sign in as a different user.
        @user2 = FactoryGirl.build(:user)
        @user2.screen_name = 'bobby'
        @user2.email = 'bob@swirrl.com'
        @user2.save!

        sign_in @user2
      end

      it_behaves_like "update_no_perms"
    end

    context 'signed in as admin user' do
      before do
        @user = FactoryGirl.create(:admin_user)
        sign_in @user
      end

      it_behaves_like "update_with_perms"
    end

  end



end