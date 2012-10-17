require 'spec_helper'

describe ReportsController do

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
      end

      it 'should not set a flash' do
        post :create
        flash[:notice].should be_nil
      end

    end

    context 'save succeeds' do

      before do
        r = FactoryGirl.build(:report)
        r.should_receive(:new_report_recipients).and_return(['email1@example.com', 'email2@example.com'])
        Report.should_receive(:new).and_return(r)
      end

      it 'should redirect to index' do
        post :create
        response.should be_redirect
      end

      it 'should send emails' do
        expect do
          post :create
        end.to change {ActionMailer::Base.deliveries.length}.by 1
      end

      it 'should set a flash message' do
        post :create
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



end