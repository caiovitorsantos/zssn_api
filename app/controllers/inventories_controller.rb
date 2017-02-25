class InventoriesController < ApplicationController
	before_action :set_inventoy, only: [:update, :destroy, :add, :remove]

	# GET /inventories/:id
	# GET /inventories/:id.json
	def show
		user_healthy = User.find(params[:id])
		if user_healthy.healthy
			@inventory = Inventory.where(user_id: params[:id])
			render json: @inventory, status: 200 
		else
  	 	render json: [:denied_access, "User is contaminated"], status: 403
  	end
	end

	# POST /inventories
	# POST /inventories.json
	def create
		@inventory = Inventory.new(inventory_params)

		if @inventory.save
			render json: @inventory, status: 201 # status code: success, created
		else
			render json: @inventory.errors, status: :unprocessable_entity
		end
	end

	# PUT /inventories/:id
	# PUT /inventories/:id.json
	def update
		if @inventory.update(inventory_params)
			 render json: @inventory, status: 200
  	else
  		render json: @inventory.errors, status: :unprocessable_entity
  	end
	end

	# DELETE /inventories/:id
	# DELETE /inventories/:id.json
	def destroy
		@inventory.destroy
	end

	# POST /inventories/:id/add
	# POST /inventories/:id/add.json
	def add
		unless User.healthy? params[:inventory][:user_id]
  	 	render json: [:denied_access, "User is contaminated"], status: 403
		else
			if @inventory.add(params[:inventory][:amount])
				render json: @inventory, status: 200
			else
				render json: @inventory.errors, status: :unprocessable_entity
			end
		end	
	end

	# POST /inventories/:id/remove
	# POST /inventories/:id/remove.json
	def remove
		unless User.healthy? params[:inventory][:user_id]
  	 	render json: [:denied_access, "User is contaminated"], status: 403
		else
			if @inventory.remove(params[:inventory][:amount])
				render json: @inventory, status: 200
			else
				render json: @inventory.errors, status: :unprocessable_entity
			end
		end
	end

	private
		def inventory_params
			params.require(:inventory).permit(:user_id, :kind, :amount)
		end

		def set_inventoy
			@inventory = Inventory.where(params.require(:inventory).permit(:user_id, :kind)).first
		end

end
