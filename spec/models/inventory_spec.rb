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
				@user = create(:user, healthy: true, count_report: 0)
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
		context "with healthy user and without reports" do 	
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
				expect(@inventory.errors.messages[:user_id][0]).to eql("The user is infected")
			end
		end
	end

	describe "#remove" do
		context "with healthy user and without reports" do 	
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

			it "does inventory must not be negative" do
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
				expect(@inventory.errors.messages[:user_id][0]).to eql("The user is infected")
			end
		end
	end

	describe "self #equality" do

		context "with healthy users and without reports" do
			before do  
				@user1 = create(:user, healthy: true, count_report: 0)
				@inventory1 = {user: @user1, kind: :water, amount: 2} 				# 8 points
				@inventory2 = {user: @user1, kind: :food, amount: 2}					# 6 points

				@user2 = create(:user, healthy: true, count_report: 0)
				@inventory3 = {user: @user2, kind: :medicine, amount: 4}			# 8 points
				@inventory4 = {user: @user2, kind: :ammunition, amount: 5}		# 5 points
				@inventory5 = {user: @user2, kind: :ammunition, amount: 1}		# 1 point 
			end
			
			it "the inventories has same points number" do
				origin = { user_id: @user1, items: [{kind: @inventory1[:kind], amount: @inventory1[:amount]},{kind: @inventory2[:kind], amount: @inventory2[:amount]}]}
				destiny = { user_id: @user2, items: [{kind: @inventory3[:kind], amount: @inventory3[:amount]},{kind: @inventory4[:kind], amount: @inventory4[:amount]}, {kind: @inventory5[:kind], amount: @inventory5[:amount]}]}

				expect(Inventory.equality(origin, destiny)).to eql(true)				
			end


			it "the inventories has no same points number" do
				origin = { user_id: @user1, items: [{kind: @inventory1[:kind], amount: @inventory1[:amount]},{kind: @inventory2[:kind], amount: @inventory2[:amount]}]}
				destiny = { user_id: @user2, items: [{kind: @inventory4[:kind], amount: @inventory4[:amount]}, {kind: @inventory5[:kind], amount: @inventory5[:amount]}]}

				expect(Inventory.equality(origin, destiny)).to eql(false)				
			end

		end

		context "with infected users and with reports" do
			before do  
				@user1 = create(:user, healthy: false, count_report: 3)
				@inventory1 = {user: @user1, kind: :water, amount: 2} 			# 8 points
				@inventory2 = {user: @user1, kind: :food, amount: 2}				# 6 points

				@user2 = create(:user, healthy: false, count_report: 3)
				@inventory3 = {user: @user2, kind: :medicine, amount: 3}		# 6 points
				@inventory4 = {user: @user2, kind: :ammunition, amount: 4}	# 4 points
				@inventory5 = {user: @user2, kind: :ammunition, amount: 1}	# 4 point
			end
			
			it "user is infected" do
				origin = { user_id: @user1, items: [{kind: @inventory1[:kind], amount: @inventory1[:amount]},{kind: @inventory2[:kind], amount: @inventory2[:amount]}]}
				destiny = { user_id: @user2, items: [{kind: @inventory3[:kind], amount: @inventory3[:amount]},{kind: @inventory4[:kind], amount: @inventory4[:amount]}, {kind: @inventory5[:kind], amount: @inventory5[:amount]}]}

				expect(Inventory.equality(origin, destiny)).to eql(false)		
			end

		end
	end

	describe "self #exchange" do 
		before do
			@user1 = create(:user, healthy: true, count_report: 0)
			create(:inventory, user: @user1, kind: :water, amount: 2) 		
			create(:inventory, user: @user1, kind: :food, amount: 2)			

			@user2 = create(:user, healthy: true, count_report: 0)
			create(:inventory, user: @user2, kind: :medicine, amount: 3)	
			create(:inventory, user: @user2, kind: :ammunition, amount: 4)
			create(:inventory, user: @user2, kind: :water, amount: 1)
		end


		context "with healthy users and without reports" do
			before do
				@inventory1 = {user: @user1, kind: :water, amount: 2} 			# 8 points
				@inventory2 = {user: @user1, kind: :food, amount: 2}				# 6 points

				@inventory3 = {user: @user2, kind: :medicine, amount: 3}		# 6 points
				@inventory4 = {user: @user2, kind: :ammunition, amount: 4}	# 4 points
				@inventory5 = {user: @user2, kind: :water, amount: 1}				# 4 points
			end

			it "users exchange items" do
				origin = { user_id: @user1.id, items: [{kind: @inventory1[:kind], amount: @inventory1[:amount]},{kind: @inventory2[:kind], amount: @inventory2[:amount]}]}
				destiny = { user_id: @user2.id, items: [{kind: @inventory3[:kind], amount: @inventory3[:amount]}, {kind: @inventory4[:kind], amount: @inventory4[:amount]}, {kind: @inventory5[:kind], amount: @inventory5[:amount]}]}

				Inventory.exchange(origin, destiny)	

				user_origin = User.find(origin[:user_id])
				user_destiny = User.find(destiny[:user_id])				

				
				# o usuário 2 recebeu do usuário 1 duas unidades de água
				expect(user_destiny.inventories.find_by(kind: :water).amount).to eql(@inventory1[:amount])				

				# o usuário 2 recebeu do usuário 1 2 unidades de comida
				expect(user_destiny.inventories.find_by(kind: :food).amount).to eql(@inventory2[:amount])				

				# o usuário 1 recebeu do usuário 2 três unidades de medicamento
				expect(user_origin.inventories.find_by(kind: :medicine).amount).to eql(@inventory3[:amount])				
				
				# o usuário 1 recebeu do usuário 2 quatro unidades de munição
				expect(user_origin.inventories.find_by(kind: :ammunition).amount).to eql(@inventory4[:amount])				
				
				# o usuário 1 recebeu do usuário 2 uma unidade de água
				expect(user_origin.inventories.find_by(kind: :water).amount).to eql(@inventory5[:amount])				
			end
		end

		context "with healthy users and without reports" do
			before do
				@user1.update(healthy: false, count_report: 3)
				@inventory1 = {user: @user1, kind: :water, amount: 2} 			# 8 points
				@inventory2 = {user: @user1, kind: :food, amount: 2}				# 6 points

				@inventory3 = {user: @user2, kind: :medicine, amount: 3}		# 6 points
				@inventory4 = {user: @user2, kind: :ammunition, amount: 4}	# 4 points
				@inventory5 = {user: @user2, kind: :water, amount: 1}				# 4 points
			end

			it "the user is infected" do
				origin = { user_id: @user1.id, items: [{kind: @inventory1[:kind], amount: @inventory1[:amount]},{kind: @inventory2[:kind], amount: @inventory2[:amount]}]}
				destiny = { user_id: @user2.id, items: [{kind: @inventory3[:kind], amount: @inventory3[:amount]}, {kind: @inventory4[:kind], amount: @inventory4[:amount]}, {kind: @inventory5[:kind], amount: @inventory5[:amount]}]}
			
				# Usuario 1 está infectado
				expect(Inventory.exchange(origin, destiny)[0]).to eql(false)				
			end
		end
	end

end
