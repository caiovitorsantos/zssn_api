require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  describe "GET #index" do
    before do
      request.env["HTTP_ACCEPT"] = "application/json"
    end

    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      before do
        request.env["HTTP_ACCEPT"] = "application/json"
      end

      it "returns http success" do
        post :create
        expect(response).to have_http_status(:success)
      end

      it "save on database" do
      end
    end
  end

  describe "PUT #update" do
    before do
      request.env["HTTP_ACCEPT"] = "application/json"
    end

    context "with valid params" do
      before do
        @user = User.last
        @user.latitude = FFaker::Geolocation::lat
        @user.longitude = FFaker::Geolocation::lng
      end

      it "returns http success" do
        put :update, params: {id: @user.id, user: @user} 
        expect(response).to have_http_status(:success)
      end

      it "save on database" do
        put :update, params: {id: @user.id, user: @user}
        user_after_update = User.last
        expect(@user).to eql(user_after_update)
      end
    end
  end

  describe "GET #complaint" do
    before do
      request.env["HTTP_ACCEPT"] = "application/json"
    end

    context "with a healthy user" do
      before do
        @user1 = create(:user, healthy: true, count_report: 2)
        @user2 = create(:user, healthy: true, count_report: 0)
      end

      it "report him and make him infected" do
        get :complaint, params: {id: @user1.id}

        @user1 = User.find(@user1.id)

        expect(@user1.healthy).to eql(false)
        expect(@user1.count_report).to eql(3)
      end

      it "report him and only add count_report" do
        get :complaint, params: {id: @user2.id}

        user_after_report = User.find(@user2.id)

        expect(user_after_report.healthy).to eql(@user2.healthy)
        expect(user_after_report.count_report).to eql(@user2.count_report + 1)
      end
    end

    context "with a infected user" do
      before do
        @user1 = create(:user, healthy: false, count_report: 3)
      end

      it "report him and make him infected" do
        get :complaint, params: {id: @user1.id}

        user_after_report = User.find(@user1.id)

        expect(user_after_report.healthy).to eql(@user1.healthy)
        expect(user_after_report.count_report).to eql(@user1.count_report + 1)
      end
    end
  end
end
  