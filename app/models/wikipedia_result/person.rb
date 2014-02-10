module WikipediaResult
  class Person < Generic
    def is_dead?
      status == "dead" ? true : false
    end

    def is_alive?
      status == "alive" ? true : false
    end
  end
end