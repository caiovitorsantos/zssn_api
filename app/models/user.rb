class User < ApplicationRecord
	has_many :inventories

	# Associa o tipo do gênero do usuário com o nome do gênero
	enum sex: [:man, :woman]

	# Atualiza a localização do usuário 
	def set_location(local)
		self.latitude = local[:latitude]
		self.longitude = local[:longitude]
		self.save
	end

	# Addiciona reportação de infecção e o status do usuário se tiver 3 ou mais denuncias
	def report_complaint
		self.count_report += 1
		self.healthy = false if count_report >= 3
		self.save
	end

	def self.healthy?(user_id)
		User.find(user_id).healthy
	end
end