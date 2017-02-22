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
        @user = create(:user)
        @user_before_post = @user
      end

      it "returns http success" do
        post :create
        expect(response).to have_http_status(:success)
      end

      it "save on database" do
        post :create
        user_after_post = User.last
        expect(@user_before_post).to eql(user_after_post)
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
        put :update
        expect(response).to have_http_status(:success)
      end

      it "save on database" do
        put :update
        user_after_post = User.last
        expect(@user).to eql(user_after_post)
      end
    end
  end



end
