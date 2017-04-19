class InventoriesController < ApplicationController
	before_action :set_inventoy, only: [:show, :update, :destroy, :add, :remove]

	def index
		unless User.healthy? params[:user_id]
  	 	render json: {error: "Denied access. User is contaminated!"}, status: 403 and return
  	end

		inventory = Inventory.where(user_id: params[:user_id])
		render json: inventory, status: 200 
	end

	# GET /inventories/:id
	# GET /inventories/:id.json
	def show
		# Se o usuário não estiver infectado, exibe os itens do seu inventário
		unless User.healthy? inventory_params[:user_id]
  	 	render json: {error: "Denied access. User is contaminated!"}, status: 403 and return
  	end

		render json: @inventory, status: 200 
	end

	# POST /inventories
	# POST /inventories.json
	def create
		# se o usuário não entiver infectado e se já não existir, cria um novo inventário
		unless User.healthy? inventory_params[:user_id]
  	 	render json: {error: "Denied access. User is contaminated!"}, status: 403 and return
  	end

		inventory = Inventory.new(inventory_params)
		
		if inventory.save
			render json: inventory, status: 201 
		else
			render json: inventory.errors, status: :unprocessable_entity
		end
			
	end

	# PUT /inventories/:id
	# PUT /inventories/:id.json
	def update
		# se o usuário não entiver infectado e se já não existir um igual salvo, atualiza o inventário
		unless User.healthy? inventory_params[:user_id]
  	 	render json: {error: "Denied access. User is contaminated!"}, status: 403 and return
  	end

		if @inventory.update(inventory_params)
			 render json: @inventory, status: 200
  	else
  		render json: @inventory.errors, status: :unprocessable_entity
  	end
	end

	# DELETE /inventories/:id
	# DELETE /inventories/:id.json
	def destroy
		# se o usuário não entiver infectado, exclui o inventário
		unless User.healthy? inventory_params[:user_id]
  	 	render json: {error: "Denied access. User is contaminated!"}, status: 403 and return
  	end

		if @inventory.destroy
		  render json: :success, status: 200
    else
      render json: @inventory.errors, status: :unprocessable_entity
    end
	end

	# POST /inventories/:id/add
	# POST /inventories/:id/add.json
	def add
		# se o usuário não entiver infectado e já existir o inventário salvo, insere a qauantidade no inventário
		unless User.healthy? inventory_params[:user_id]
  	 	render json: {error: "Denied access. User is contaminated!"}, status: 403
		else
			if @inventory.add(inventory_params[:amount].to_i)
				render json: @inventory, status: 200
			else
				render json: @inventory.errors, status: :unprocessable_entity
			end
		end	
	end

	# POST /inventories/:id/remove
	# POST /inventories/:id/remove.json
	def remove
		# se o usuário não entiver infectado e já existir o inventário salvo, remove a qauantidade no inventário
		unless User.healthy? inventory_params[:user_id]
  	 	render json: {error: "Denied access. User is contaminated!"}, status: 403
		else
			if @inventory.remove(inventory_params[:amount].to_i)
				render json: @inventory, status: 200
			else
				render json: @inventory.errors, status: :unprocessable_entity
			end
		end
	end

	# POST /inventories/:exchange
	# POST /inventories/:exchange.json
	def exchange
		# se os usuários não entiverem infectados e os pontosdos items serem iguais, executa o escambo entre os usuários

		data_origin, data_destiny = origin_params, destiny_params

		unless (User.healthy?(data_origin[:user_id]) && User.healthy?(data_destiny[:user_id]))
  		render json: {error: "Denied access. User is contaminated!"}, status: 403 and return
		end

		unless Inventory.equality(data_origin, data_destiny)
			render json: {error: "The items points aren't equal!"}, status: 400 and return
		end

		Inventory.exchange(data_origin, data_destiny)

		render json: :success, status: 200
	end

	private
		def set_inventoy
			@inventory = Inventory.where(params.require(:inventory).permit(:user_id, :kind)).first
		end

		def inventory_params
			params.require(:inventory).permit(:user_id, :kind, :amount).merge(id: params[:id])
		end

		def origin_params  
  		params.require(:origin).permit(:user_id, items: [:kind, :amount]) 
		end

		def destiny_params
			params.require(:destiny).permit(:user_id, items: [:kind, :amount])
		end

end
