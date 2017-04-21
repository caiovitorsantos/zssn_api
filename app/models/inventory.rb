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

  # Retorna ponto do tipo de suprimento do objeto
  def get_point
    @@points[Inventory.kinds[self.kind]]
  end

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

  # Verifica se os itens a serem trocados tem a mesmma quantidade de pontos, para uma troca igual 
  def self.equality(data_origin, data_destiny)
    user_origin = User.find(data_origin[:user_id])
    user_destiny = User.find(data_destiny[:user_id])
    user_origin.errors.add(:base, "The user is infected") and return false unless user_origin.healthy?
    user_destiny.errors.add(:base, "The user is infected") and return false unless user_destiny.healthy?

    points_origin = points_destiny = 0

    data_origin[:items].each do |item|
      points_origin += item[:amount].to_i * @@points[Inventory.kinds[item[:kind]]]
    end    

    data_destiny[:items].each do |item|
      points_destiny += item[:amount].to_i * @@points[Inventory.kinds[item[:kind]]]
    end    

    points_origin == points_destiny    
  end

  # Realiza a troca bilateral do items entre dois usuário
  # Da forma que estruturado esse método é possível realizar uma troca unilateral passando o terceiro paramentro com
  # o valor true 
  def self.exchange(data_origin, data_destiny, recursed = false)
    data_origin[:items].each do |item|  
      inv_sub = Inventory.where(user_id: data_origin[:user_id], kind: item[:kind]).first

      if inv_sub.nil?
        return false, "The inventory doesn't exist to remove items"
      end

      unless inv_sub.user.healthy?
        return false, "The user #{inv_sub.user.name} is infected"
      end

      inv_add = Inventory.where(user_id: data_destiny[:user_id], kind: item[:kind]).first_or_create do |user|
        user.user_id = data_destiny[:user_id]
        user.kind = item[:kind]
        user.amount ||= 0
      end

      inv_add.amount += item[:amount].to_i
      inv_sub.amount -= item[:amount].to_i
      inv_add.save
      inv_sub.save
    end

    self.exchange(data_destiny, data_origin, true) unless recursed

    return true
  end
end