class Kor::Graph
  
  # Constructor
  
  def initialize(options = {})
    @options = options
  end
  
  
  # Main

  def find_paths(specs = [])
    if specs.size > 2
      db = ActiveRecord::Base.connection

      query = []
      fields
      conditions = []
      binds = []

      specs.each_with_index do |spec, i|
        index = i / 2

        if i == 0
          fields << "es_#{index}.id AS es_#{index}_id"
          fields << "es_#{index}.kind_id AS es_#{index}_kind_id"
          fields << "es_#{index}.name AS es_#{index}_name"
          query << nil

        elsif i == 1

        else
          if i % 2 == 0
            fields << "es_#{index}.id AS es_#{index}_id"
            fields << "es_#{index}.kind_id AS es_#{index}_kind_id"
            fields << "es_#{index}.name AS es_#{index}_name"
            query << "INNER JOIN entities AS es_#{index} ON es_#{index} = rels_#{index - 1}.to_id"            

            if spec['id']
              value = [spec['id']] if spec['id'].is_a?(String)
              conditions << "es_#{index}.id IN ?"
              binds << value
            end
          else
            fields << "es_#{index}.id AS es_#{index}_id"
            fields << "es_#{index}.kind_id AS es_#{index}_kind_id"
            fields << "es_#{index}.name AS es_#{index}_name"
            query << "INNER JOIN relationships AS relationships_#{index} ON es_#{index}.id = rels_#{index}.from_id"

            if spec['name']
              value = [spec['name']] if spec['name'].is_a?(String)
              query << "INNER JOIN relations AS rs_#{index} ON rels_#{index}.relation_id = rs_#{index}.id"
              conditions << "rs_#{index}.name IN ?"
              binds << value
            end
          end
        end
      end

      fields = fields.join(', ')
      query[0] = "SELECT #{fields} FROM relationships AS rels_0"

      query = query.join("\n")
      conditions = conditions.join("\n")

      puts query.join("\n")
    else
      []
    end
  end
  
  def search(type, options = {})
    Kor::Graph::Search.create(type, user, options)
  end
  
  def results_from(object)
    Kor::Graph::Search::Result.from(object)
  end
  
  
  # Accessors
  
  def user
    @options[:user]
  end
  
end
