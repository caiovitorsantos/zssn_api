class UsersController < ApplicationController
	before_action :set_user, only: [:update, :destroy, :complaint, :inventory, :set_location]

	# GET /users
	# GET /users/index.json
  def index
    # Lista todos os usuários
  	users = User.all
  	render json: users, status: 200
  end

	# GET /users/id
	# GET /users/id.json
  def show
    # Exibe detalhes do usuário informado
  	user = User.find(params[:id])
  	render json: user, status: 200
  end

  # POST /users
  # POST /users.json
  def create
    # Cria um novo usuário
  	user = User.new(users_params)
  	if user.save
  		render json: :success, status: 201
  	else
  		render json: user.errors, status: :unprocessable_entity
  	end
  end

  # PUT /users/id
  # PUT /users/id.json
  def update
    # Atualiza as informações o usuário
  	if @user.update(users_params) 
  		render json: :success, status: 200
  	else
  		render json: @user.errors, status: :unprocessable_entity
  	end
  end

  # DELETE /users/id
  # DELETE /users/id.json
  def destroy
    # Exclui o usuário
    if @user.destroy
      render json: :success, status: 200
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PUT /users/id/set_location
  # PUT /users/id/set_location.json
  def set_location
    # Atualiza as informações o usuário
    if @user.set_location(users_location_params) 
      render json: :success, status: 200
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # GET /users/id/complaint
  # GET /users/id/complaint.json
  def complaint
    # Incrementa um denunncia de infecção ao usuário, se houver 3 ou mais o usuário se torna infectado
    if @user.report_complaint
  		render json: [:success, @user.healthy], status: 200
  	else
  		render json: @user.errors, status: :unprocessable_entity
  	end
  end

  def inventory
    # Se o usuário não estiver infectado, exibe os itens do seu inventário
  	unless @user.healthy
  	 	render json: [:denied_access, "User is contaminated"], status: 403
  	else
  		@inventory = Inventory.where(user_id: @user.id)
  		render json: @inventory
  	end 
  end

  def reports
    avg_inventory = {}
    infected_points = 0

    # Seleciona todos os usuários infectados e retorna sua porcentagem comparado com todos os usuários
    infected_users = (User.where(healthy: false).count  * 100).to_f  / User.all.count

    # Seleciona todos os usuários saldáveis e retorna sua porcentagem comparado com todos os usuários
    healthy_users = (User.where(healthy: true).count  * 100).to_f / User.all.count

    # Soma as quantidades de suprimentos agrupando-os pelo seu tipo, para cada tipo pelo total de usuários 
    Inventory.all
      .group(:kind)
      .sum(:amount)
      .each { |inventory| avg_inventory[inventory[0]] = (inventory[1] / User.all.count).to_f }

    # Soma os numeros de pontos de suprimentos pertencentes aos usuários infectados
    Inventory.select(:kind, :amount).all
      .joins(:user)
      .where(users: {healthy: false})
      .each { |inventory| infected_points += inventory.amount * inventory.get_point }

    render json:{ infected_users: infected_users,
                  healthy_users: healthy_users,
                  average_inventory_per_user: avg_inventory,
                  points_of_infected_users: infected_points }
  end

  private

  	def set_user
  		@user = User.find(params[:id])
  	end

	  def users_params
      params.require(:user).permit( :name, :age, :sex, :healthy, :count_report, :latitude, :longitude)
    end

    def users_location_params
	  	params.require(:user).permit(:latitude, :longitude)
	  end

end
