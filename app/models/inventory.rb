class Inventory < ApplicationRecord

  belongs_to :user

  # Associa os possíveis tipos de suprimentos com seu nome
  enum kind: [:water, :food, :medicine, :ammunition]

  # Associa cada suprimento com sua pontuação para troca
  @@points = [ 4,  3,  2, 1]

  # Todo objeto deve conter, pelo menos, o id do usuário e o tipo do suprimento
  validates_presence_of :user_id, :kind

  # A quantidade de um suprimento não deve ser negativa 
  validates_numericality_of :amount, greater_than_or_equal_to: 0, message: "Amount cannot be negative"
  
	# Valida o index unique definido no banco, ou seja, permite que seja inserido apenas um par de valores  
  validates :user_id, uniqueness: { scope: :kind }

  # Adiciona unidades do item no seu inventário
  def add(amount_inc)
    unless self.user.healthy?
      self.errors.add(:user_id, "The user is infected") and return false
    end

  	self.amount ||= 0
  	self.amount += amount_inc
  	self.save
  end

  # Remove unidades do item no seu inventário e retornado a mensagem de erro se o novo valor for negativo
  def remove(amount_inc)
    unless self.user.healthy?
      self.errors.add(:user_id, "The user is infected") and return false
    end

  	self.amount ||= 0
  	self.amount -= amount_inc
  	self.save
  end

  # 
  def self.equality(data_origin, data_destiny)
    points_origin = points_destiny = 0
      
    data_origin[:items].each do |item|
        points_origin += item[:amount] * @@points[item[:kind]]
    end    

    data_destiny[:items].each do |item|
        points_destiny += item[:amount] * @@points[item[:kind]]
    end    

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