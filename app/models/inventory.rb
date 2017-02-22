class Inventory < ApplicationRecord
  belongs_to :user

  points = [water: 4, food: 3, medicines: 2, ammunition: 1].freeze
  enum kind: [ :water, :food, :medicines, :ammunition ]


end
