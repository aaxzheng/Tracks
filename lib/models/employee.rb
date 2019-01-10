require_relative './app_record/act_rec'
DBConnection.open("../../db/trains.db")

class Employee < SQLObject
  attr_accessor :id,:name,:train_id

  belongs_to :train

end

class Train < SQLObject
  attr_accessor :id,:name,:maker,:year

  has_many :employees,
  primary_key: :id,
  foreign_key: :train_id,
  class_name: 'Employee'
end
