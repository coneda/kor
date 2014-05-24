Transform /^table:name,distinct_name,kind,collection/ do |table|
  table.map_column!(:distinct_name) {|d| d == "" ? nil : d}
  table.map_headers! {|h| h.to_sym}
  table
end

Then /^the following entities should exist:$/ do |table|
  table.hashes.each do |h|
    Entity.
      includes(:collection, :kind).
      where("collections.name LIKE ?", h[:collection]).
      where("kinds.name LIKE ?", h[:kind]).
      where(:name => h[:name]).
      where(:distinct_name => h[:distinct_name]).
      count.should == 1
  end
end

Then /^user "([^"]*)" should have the following access rights$/ do |user, table|
  user = User.find_by_name(user)
  
  results = []
  
  user.groups.each do |group|
    group.grants.each do |grant|
      results << {
        'collection' => grant.collection.name,
        'credential' => group.name,
        'policy' => grant.policy
      }
    end
  end
  
  if results.size == 0
    table.hashes.size.should == 0
  else
    table.diff! results
  end
end
