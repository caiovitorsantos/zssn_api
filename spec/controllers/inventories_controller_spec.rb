require 'rails_helper'

RSpec.describe InventoriesController, type: :controller do
	describe "POST #add" do
		before do
			@user = create(:user)
			@inventory = create(:inventory, user: @user)
			request.env["HTTP_ACCEPT"] = 'application/json'
		end

		context "with post data valid" do
			it "add new amount to the inventory" do
				last_amount = @inventory.amount
				post :add, {inventory: {user_id: @inventory.user.id, kind: @inventory.kind, amount: @inventory.amount}}
				expect(JSON.parse(response.body)[inventory][amount]).to eql(@inventory.amount * 2)
			end

		end

	end
end