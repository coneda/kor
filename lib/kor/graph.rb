class Kor::Graph
  
  # Constructor
  
  def initialize(options = {})
    @options = options
  end
  
  
  # Main

  def find_paths(specs = [])
    collection_ids = ::Auth::Authorization.authorized_collections(@options[:user]).map{|c| c.id}

    return [] if collection_ids.empty?

    if specs.size > 2
      db = ActiveRecord::Base.connection

      query = []
      fields = []
      conditions = []
      binds = []

      specs.each_with_index do |spec, i|
        index = i / 2

        if i == 0
          fields << "es_#{index}.id AS es_#{index}_id"
          fields << "es_#{index}.kind_id AS es_#{index}_kind_id"
          fields << "es_#{index}.name AS es_#{index}_name"
          query << "JOIN entities AS es_#{index} ON es_#{index}.id = rels_#{index}.from_id"

          values = collection_ids.join(',')
          conditions << "es_#{index}.collection_id IN (#{values})"

          if spec['id']
            value = [spec['id']] if spec['id'].is_a?(String)
            conditions << "es_#{index}.id IN ?"
            binds << value
          end

          if spec['kind_id']
            value = [spec['kind_id'].to_i]
            conditions << "es_#{index}.kind_id IN (#{value.join(',')})"
          end
        elsif i == 1
          fields << "rels_#{index}.id AS rels_#{index}_id"
          fields << "rels_#{index}.relation_id AS rels_#{index}_relation_id"
          fields << "rs_#{index}.name AS rs_#{index}_name"
          fields << "rs_#{index}.reverse_name AS rs_#{index}_reverse_name"
          fields << "rels_#{index}.reverse AS rels_#{index}_reverse"
          query << "JOIN relations AS rs_#{index} ON rels_#{index}.relation_id = rs_#{index}.id"

          if spec['name']
            rels = Relation.where(:name => spec['name']).pluck(:id)
            reverse_rels = Relation.where(:reverse_name => spec['name']).pluck(:id)
            name_conditions = []
            if rels.present?
              name_conditions << "(rels_#{index}.relation_id IN (#{rels.join(',')}) AND NOT rels_#{index}.reverse)"
            end
            if reverse_rels.present?
              name_conditions << "(rels_#{index}.relation_id IN (#{rels.join(',')}) AND rels_#{index}.reverse)"
            end
            conditions << name_conditions.join(' OR ')
          end
        else
          if i % 2 == 0
            fields << "es_#{index}.id AS es_#{index}_id"
            fields << "es_#{index}.kind_id AS es_#{index}_kind_id"
            fields << "es_#{index}.name AS es_#{index}_name"
            query << "JOIN entities AS es_#{index} ON es_#{index}.id = rels_#{index - 1}.to_id"

            values = collection_ids.join(',')
            conditions << "es_#{index}.collection_id IN (#{values})"

            if spec['id']
              value = [spec['id']] if spec['id'].is_a?(String)
              conditions << "es_#{index}.id IN ?"
              binds << value
            end

            if spec['kind_id']
              value = [spec['kind_id'].to_i]
              conditions << "es_#{index}.kind_id IN (#{value.join(',')})"
            end
          else
            fields << "rels_#{index}.id AS rels_#{index}_id"
            fields << "rels_#{index}.relation_id AS rels_#{index}_relation_id"
            fields << "rs_#{index}.name AS rs_#{index}_name"
            fields << "rs_#{index}.reverse_name AS rs_#{index}_reverse_name"
            fields << "rels_#{index}.reverse AS rels_#{index}_reverse"
            query << "JOIN directed_relationships AS rels_#{index} ON es_#{index}.id = rels_#{index}.from_id"
            query << "JOIN relations AS rs_#{index} ON rels_#{index}.relation_id = rs_#{index}.id"
            
            if spec['name']
              rels = Relation.where(:name => spec['name']).pluck(:id)
              reverse_rels = Relation.where(:reverse_name => spec['name']).pluck(:id)
              name_conditions = []
              if rels.present?
                name_conditions << "(rels_#{index}.relation_id IN (#{rels.join(',')}) AND NOT rels_#{index}.reverse)"
              end
              if reverse_rels.present?
                name_conditions << "(rels_#{index}.relation_id IN (#{rels.join(',')}) AND rels_#{index}.reverse)"
              end
              conditions << name_conditions.join(' OR ')
            end
          end

          if i >= 4
            if i % 2 == 0
              conditions << "es_#{index}.id != es_#{index - 2}.id"
            else
              # conditions <<
            end
          end
        end
      end

      fields = fields.join(', ')
      init = ["SELECT #{fields} FROM directed_relationships AS rels_0"]

      query = (init + query).join("\n")
      conditions = conditions.map{|c| "(#{c})"}.join(" AND ")

      final = "#{query}" + (conditions.present? ? " WHERE #{conditions}" : "")
      # puts final

      db.select_all(final).map do |r|
        specs.each_with_index.map do |spec, i|
          index = i / 2

          if i % 2 == 0
            {
              'id' => r["es_#{index}_id"]
            }
          else
            {
              'id' => r["rels_#{index}_id"],
              'relation_id' => r["rels_#{index}_relation_id"],
              'relation_name' => r["rs_#{index}_name"],
              'relation_reverse_name' => r["rs_#{index}_reverse_name"],
              'reverse' => (r["rels_#{index}_reverse"] == 0 ? false : true)
            }
          end
        end
      end
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
