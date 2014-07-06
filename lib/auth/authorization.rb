module Auth::Authorization

  def self.authorized_collections(user, policies = :view)
    result = Grant.where(
      :credential_id => user.groups.map{|c| c.id}, 
      :policy => policies
    ).group(:collection_id).count
    
    Collection.where(:id => result.keys).to_a
  end
  
  def self.authorized?(user, policy = :view, collections = Collection.all, options = {})
    options.reverse_merge!(:required => :all)
    collections = [collections] unless collections.is_a? Array
    collections = collections.reject{|c| c.nil?}
    
    result = Grant.where(
      :credential_id => user.groups.map{|c| c.id},
      :policy => policy,
      :collection_id => collections.map{|c| c.id}
    ).group(:collection_id).count
    
    if options[:required] == :all
      result.keys.size == collections.size
    else
      result.keys.size > 0
    end
  end
  
end
