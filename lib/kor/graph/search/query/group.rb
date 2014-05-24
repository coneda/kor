class Kor::Graph::Search::Query::UserGroup < Kor::Graph::Search::Query::Base
  
  # Constructor
  
  def initialize(user, options = {})
    options.reverse_merge!(
      :media => false,
      :per_page => 16
    )
        
    super user, options
  end
  
  
  # Main
  
  def ids
    run
  end
  
  def items
    Entity.find_all_by_id_keep_order(ids)
  end
  
  
  # Processing

  private

    def execute
      user_group = UserGroup.owned_by(user).find_by_name(criteria(:name))
      
      if user_group
        records = UserGroup.connection.execute("
          SELECT jt.entity_id id
          FROM entities_user_groups jt
            LEFT JOIN entities e ON e.id = jt.entity_id
            LEFT JOIN user_groups u ON u.id = jt.user_group_id
          WHERE u.name LIKE '#{user_group.name}'
        ")
        
        result = []
        records.each_hash do |row|
          result << row['id']
        end
        result
      else
        []
      end
    end
  
end
