class Person
  include ActiveModel::Model

  attr_accessor :name, :status

  def is_dead?
    status == "dead" ? true : false
  end
end