class Inventory < ApplicationRecord
  belongs_to :user

  enum kind: [:water, :food, :medicine, :ammunition]
  points = [water: 4, food: 3, medicine: 2, ammunition: 1]

  validates_presence_of :user_id, :kind
  validates_numericality_of :amount, greater_than_or_equal_to: 0, message: "Amount cannot be negative"
  
	# Valida o index unique definido no banco, ou seja, permite que seja inserido apenas um par de valores  
  validates :user_id, uniqueness: { scope: :kind }

  def add(amount_inc)
  	self.amount ||= 0
  	self.amount += amount_inc
  	self.save
  end

  def remove(amount_inc)
  	self.amount ||= 0
  	self.amount -= amount_inc
  	self.save
  end
end
