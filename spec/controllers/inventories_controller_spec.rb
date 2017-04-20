require 'rails_helper'

RSpec.describe InventoriesController, type: :controller do

	describe "POST #exchange" do
		before do
			request.env["HTTP_ACCEPT"] = 'application/json'


			# Criando os usuários e seus inventarios
			@user1 = create(:user, healthy: true, count_report: 0)
			create(:inventory, user: @user1, kind: :water, amount: 2) 		
			create(:inventory, user: @user1, kind: :food, amount: 2)			

			@user2 = create(:user, healthy: true, count_report: 0)
			create(:inventory, user: @user2, kind: :medicine, amount: 3)	
			create(:inventory, user: @user2, kind: :ammunition, amount: 4)
			create(:inventory, user: @user2, kind: :water, amount: 1)
		end

		context "with post data valid" do
			before do  

				# Montando os objetos para serem passados na requisição 
				@inventory1 = {user: @user1, kind: :water, amount: 2} 			# 8 points
				@inventory2 = {user: @user1, kind: :food, amount: 2}	  		# 6 points

				@inventory3 = {user: @user2, kind: :medicine, amount: 3}		# 6 points
				@inventory4 = {user: @user2, kind: :ammunition, amount: 4}	# 4 points
				@inventory5 = {user: @user2, kind: :water, amount: 1}				# 4 points

				@origin = { user_id: @user1.id, items: [{kind: @inventory1[:kind], amount: @inventory1[:amount]},{kind: @inventory2[:kind], amount: @inventory2[:amount]}]}
				@destiny = { user_id: @user2.id, items: [{kind: @inventory3[:kind], amount: @inventory3[:amount]}, {kind: @inventory4[:kind], amount: @inventory4[:amount]}, {kind: @inventory5[:kind], amount: @inventory5[:amount]}]}

			end

			it "return success with status 200" do
				post :exchange, params: {origin: @origin, destiny: @destiny}

				expect(response).to have_http_status(200)
			end

			it "failed, because origin and destiny haven't same points quantity" do
				# Incluindo mais um Objeto para para haver mais pontos de uma lado
				@origin[:items] << {kind: @inventory3[:kind], amount: @inventory3[:amount]}

				post :exchange, params: {origin: @origin, destiny: @destiny}

				expect(response).to have_http_status(400)				
				expect(JSON.parse(response.body)["error"]).to eql("The items points aren't equal!")
			end

			it "deny access, because of the infected user" do
				# O usuario foi infectado
				@user1.update(healthy: false, count_report: 3)

				post :exchange, params: {origin: @origin, destiny: @destiny}

				expect(response).to have_http_status(403)				
				expect(JSON.parse(response.body)["error"]).to eql("Denied access. User is contaminated!")
			end
		end
	end

	describe "POST #add" do
		before do
			@user = create(:user, healthy: true, count_report: 0)
			@inventory = create(:inventory, user: @user)
			request.env["HTTP_ACCEPT"] = 'application/json'
		end

		context "with post data valid" do
			it "add new amount to the inventory" do
				# Incluindo item à um inventário ja existente
				last_amount = @inventory.amount
				post :add, params: {id: @inventory.user.id, inventory: {user_id: @inventory.user.id, kind: @inventory.kind, amount: @inventory.amount}}

				expect(JSON.parse(response.body)["amount"]).to eql(@inventory.amount * 2)
			end

			it "deny access, because of the infected user" do
				# O usuario foi infectado, não pode incluir
				@user.update(healthy: false, count_report: 3)

				last_amount = @inventory.amount
				post :add, params: {id: @inventory.user.id, inventory: {user_id: @inventory.user.id, kind: @inventory.kind, amount: @inventory.amount}}

				expect(JSON.parse(response.body)["error"]).to eql("Denied access. User is contaminated!")
			end
		end
	end

	describe "POST #remove" do
		before do
			@user = create(:user, healthy: true, count_report: 0)
			@inventory = create(:inventory, user: @user)
			request.env["HTTP_ACCEPT"] = 'application/json'
		end

		context "with post data valid" do

			it "remove 1 unit to the inventory" do
				# Retirando um item de seu inventário
				last_amount = @inventory.amount
				post :remove, params: {id: @inventory.user.id, inventory: {user_id: @inventory.user.id, kind: @inventory.kind, amount: 1}}

				expect(JSON.parse(response.body)["amount"]).to eql(@inventory.amount - 1)
			end

			it "clean the amount to the inventory" do
				# Retirando todos os itens de seu inventário
				last_amount = @inventory.amount
				post :remove, params: {id: @inventory.user.id, inventory: {user_id: @inventory.user.id, kind: @inventory.kind, amount: @inventory.amount}}

				expect(JSON.parse(response.body)["amount"]).to eql(0)
			end

			it "deny access, because of the infected user" do
				# O usuario foi infectado, não pode retirar itens no inventário
				@user.update(healthy: false, count_report: 3)

				last_amount = @inventory.amount
				post :remove, params: {id: @inventory.user.id, inventory: {user_id: @inventory.user.id, kind: @inventory.kind, amount: 2}}

				expect(JSON.parse(response.body)["error"]).to eql("Denied access. User is contaminated!")
			end
		end
	end

	describe "GET #show" do 
		before do
			request.env['HTTP_ACCEPT'] = 'application/json'
			@user = create(:user, healthy: true, count_report: 0)
		end

		context "with valid params" do 
			before do  
				@inventory = create(:inventory, user: @user)
			end

			it "return the inventory item" do
				# Exibindo detalhes dos inventários do usuário
				get :show, params: {id: @inventory.id, inventory: {user_id: @user.id, kind: @inventory.kind}}

				expect(response).to have_http_status(200)
				expect(JSON.parse(response.body)["id"]).to eql(Inventory.last.id)
			end

			it "deny access, because infected user" do
				# O usuario foi infectado, o usuário não pode ver seu inventário
				@user.update(healthy: false, count_report: 3)
				get :show, params: {id: @inventory.id, inventory: {user_id: @user.id, kind: @inventory.kind}}

				expect(JSON.parse(response.body)["error"]).to eql("Denied access. User is contaminated!")
			end
		end			 
	end

	describe "GET #index" do 
		before do
			request.env['HTTP_ACCEPT'] = 'application/json'
			@user = create(:user, healthy: true, count_report: 0)
		end

		context "with valid params" do 
			before do  
				@inventory1 = create(:inventory, user: @user, kind: :water)
				@inventory2 = create(:inventory, user: @user, kind: :food)
				@inventory3 = create(:inventory, user: @user, kind: :medicine)
			end

			it "return the 3 inventory item" do
				# Exibindo todos os inventários do usuário
				get :index, params: {user_id: @user.id}

				expect(response).to have_http_status(200)
				expect(JSON.parse(response.body).count).to eql(3)
			end

			it "deny access, because infected user" do
				# O usuario foi infectado, o usuário não pode ver seu inventário
				@user.update(healthy: false, count_report: 3)
				get :index, params: {user_id: @user.id}

				expect(JSON.parse(response.body)["error"]).to eql("Denied access. User is contaminated!")
			end
		end			 
	end

	describe "POST #create" do 
		before do
			request.env['HTTP_ACCEPT'] = 'application/json'
			@user = create(:user, healthy: true, count_report: 0)
		end

		context "with valid params" do
			it "return the inventory item" do
				# Criando o inventário
				post :create, params: {inventory: {user_id: @user.id, kind: :water, amount: 6}}

				expect(response).to have_http_status(201)
				expect(JSON.parse(response.body)["id"]).to eql(Inventory.last.id)
			end

			it "return the error, because inventory kind is not exist" do
				# falha, para criar o inventário é necessário o usuário o tipo do suprimento
				post :create, params: {inventory: {user_id: @user.id, amount: 6}}

				expect(response).to have_http_status(422)
			end

			it "deny access, because infected user" do
				# O usuario foi infectado, não pode incluir outro Inventário
				@user.update(healthy: false, count_report: 3)

				post :create, params: {inventory: {user_id: @user.id, kind: :water, amount: 6}}

				expect(JSON.parse(response.body)["error"]).to eql("Denied access. User is contaminated!")
			end
		end
	end

	describe "PUT #update" do 
		before do
			request.env['HTTP_ACCEPT'] = 'application/json'
			@user = create(:user)
		end

		context "with valid params" do 
			before do  
				@inventory = create(:inventory, user: @user)
			end

			it "return the inventory item" do
				put :update, params:  {id: @inventory.id, inventory: {user_id: @user.id, kind: @inventory.kind, amount: 6}}

				expect(JSON.parse(response.body)["amount"]).not_to eql(@inventory.amount)
			end
		end
	end

	describe "DELETE #destroy" do 
		before do
			request.env['HTTP_ACCEPT'] = 'application/json'
			@user = create(:user)
		end

		context "with valid params" do 
			before do  
				@inventory = create(:inventory, user: @user, kind: :water)
			end

			it "return the inventory item" do
				delete :destroy, params: {id: @inventory.id, inventory: {user_id: @user.id, kind: @inventory.kind}}

				expect(@inventory.id).not_to eql(Inventory.last.id)
			end
		end	
	end

end