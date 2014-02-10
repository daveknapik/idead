module WikipediaResult
  class Generic
    include ActiveModel::Model

    attr_accessor :name, :status
  end
end