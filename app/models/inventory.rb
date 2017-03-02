class Inventory < ApplicationRecord
  belongs_to :user

  enum kind: [:water, :food, :medicine, :ammunition]
  @@points = [ 4,  3,  2, 1]

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

  def self.equality(data_origin, data_destiny)
    points_origin = points_destiny = 0
      

    binding.pry
    data_origin[:items].each do |item|
        points_origin += item[:amount] * @@points[item[:kind]]
    end    

    data_destiny[:items].each do |item|
        points_destiny += item[:amount] * @@points[item[:kind]]
    end    
    
    puts "Origin: #{points_origin} - Destiny: #{points_destiny}"

    points_origin == points_destiny    
  end


end
=begin
{
  "origin":
  {
    "user_id":1,
    "items":[
      { "kind":0, "amount":3 },
      { "kind":2, "amount":1 }
    ]
  },
  "destiny":
  {
    "user_id":2,
    "items":[
      { "kind":0, "amount":3 },
      { "kind":2, "amount":1 }
    ]
  }
  
}
=end