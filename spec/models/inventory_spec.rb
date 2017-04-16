require 'rails_helper'

RSpec.describe Inventory, type: :model do

	describe "#create"do 
		context	"with all values and healthy user" do 
			before do
				@user = create(:user, healthy: true, count_report: rand(0..2))
				@inventory_params = {user_id: @user.id, kind: :food, amount: 9}
			end

			it "save the inventory" do
				inventory = Inventory.new(@inventory_params)
				expect(inventory.save).to eql(true)
			end

			it "don't save with same user and kind" do
				Inventory.create(@inventory_params)
				inventory = Inventory.new(@inventory_params)
				expect(inventory.save).to eql(false)
			end
		end

		context	"without all required values" do 
			before do
				@user = create(:user, healthy: true, count_report: rand(0..2))
			end

			it "don't save the inventory without the kind" do
				# Inventário sem o tipo do item que vai ser adicionado, não será salvo
				@inventory_params = {user_id: @user.id, amount: 9}
				inventory = Inventory.new(@inventory_params)
				expect(inventory.save).to eql(false)
			end

			it "don't save the inventory with amount negative" do
				# Inventário com o tipo do item só que com sua quanntidade negativa, não será salvo
				@inventory_params = {user_id: @user.id, kind: :water, amount: -9}

				inventory = Inventory.new(@inventory_params)
				expect(inventory.save).to eql(false)
			end
		end
	end

	describe "#add" do
		context "with healthy user and without report" do 	
			before do			
				@user = create(:user, healthy: true, count_report: 0)
				@inventory = create(:inventory, user: @user)
			end

			it "add 5 units of kind inventory" do
				old_amount = @inventory.amount
				@inventory.add(5)
				expect(@inventory.amount).to eql(old_amount + 5)
			end
		end

		context "with infected user" do 	
			before do			
				@user = create(:user, healthy: false, count_report: 3)
				@inventory = create(:inventory, user: @user)
			end

			it "it will not be able to add" do
				expect(@inventory.add(5)).to eql(false)
			end
		end
	end

	describe "#remove" do
		context "with healthy user and without report" do 	
			before do			
				@user = create(:user, healthy: true, count_report: 0)
				@inventory = create(:inventory, user: @user, amount: 10)
			end

			it "remove 5 units of kind inventory" do
				old_amount = @inventory.amount
				@inventory.remove(5)
				expect(@inventory.amount).to eql(old_amount - 5)
			end

			it "clean the kind inventory" do
				@inventory.remove(@inventory.amount)
				expect(@inventory.amount).to eql(0)
			end

			it "Does inventory must not be negative" do
				expect(@inventory.remove(@inventory.amount + 1)).to eql(false)
			end
		end
			
		context "with infected user" do 	
			before do			
				@user = create(:user, healthy: false, count_report: 3)
				@inventory = create(:inventory, user: @user)
			end

			it "it will not be able to remove" do
				expect(@inventory.remove(1)).to eql(false)
			end
		end
	end

end
