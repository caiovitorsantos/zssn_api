class User < ApplicationRecord

	has_many :inventories

	enum sex: [:man, :woman]

	def set_location(lat, lng)
		self.latitude = lat
		self.longitude = lng
	end

	def add_report
		count_report += 1
		healthy = false if count_report >= 3
	end

	def self.healthy?(user_id)
		User.find(user_id).healthy
	end

end