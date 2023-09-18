module ProcessersHelper 
    def processers_collection
        Processer.all.decorate.map { |processer| [processer.display_name, processer.id] } 
    end
end
