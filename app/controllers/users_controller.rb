class UsersController < ApplicationController
	before_action :set_user, only: [:update, :report, :inventory]

	# GET /users
	# GET /users/index.json
  def index
  	@users = User.all
  	render json: @users, status: 200
  end

	# GET /users/id
	# GET /users/id.json
  def show
  	@user = User.find(params[:id])
  	render json: @user, status: 200
  end

  # POST /users
  # POST /users.json
  def create
  	@user = User.new(users_params)
  	if @user.save
  		render json: :success, status: 200
  	else
  		render json: @user.errors, status: :unprocessable_entity
  	end
  end

  # PUT /users/id
  # PUT /users/id.json
  def update
  	if @user.update(params.require(:users).permit(:id, :latitude, :longitude)) 
  		render json: :success, status: 200
  	else
  		render json: @user.errors, status: :unprocessable_entity
  	end
  end

  # GET /users/id/report
  # GET /users/id/report.json
  def report
  	@user.count_report += 1

  	if @user.count_report >= 3 and @user.healthy
  		@user.healthy = false
  	end
  	if @user.save
  		render json: [:success, @user.healthy], status: 200
  	else
  		render json: @user.errors, status: :unprocessable_entity
  	end
  end

  def inventory
  	unless @user.healthy
  	 	render json: [:denied_access, "User are contaminated"], status: 403
  	else
  		@inventory = Inventory.where(user_id: @user.id)
  		render json: @inventory
  	end 
  	
  end

  private

  	def set_user
  		@user = User.find(params[:id])
  	end

	  def users_params
	  	params.permit( :name, :age, :sex, :healthy, :count_report, :latitude, :longitude) #:id,
	  end

end
