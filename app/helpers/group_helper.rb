# encoding: utf-8

module GroupHelper

  def authority_group_with_ancestors(group, options = {})
    options.reverse_merge!(:link => false)
  
    prefix = (group.authority_group_category ? ancestors_for(group.authority_group_category, :link => false) + " » " : "")
    prefix + (options[:link] ? link_to(group.name, group) : group.name)
  end

  def ancestors_for(nested_set, options = {})
    options.reverse_merge!(:link => true)
    nested_set.self_and_ancestors.map do |c| 
      if options[:link]
        link_to(c.name, c)
      else
        c.name
      end
    end.join(" » ").html_safe
  end
  
  def authority_group_categories_options
    AuthorityGroupCategory.all.map do |c|
      [ ancestors_for(c, :link => false), c.id ]
    end.sort{|x,y| x[0] <=> y[0] }
  end
  
  def authority_groups_options
    AuthorityGroup.all.map do |g|
      if g.authority_group_category
        [ authority_group_with_ancestors(g), g.id ]
      else
        [ g.name, g.id ]
      end
    end.sort{|x,y| x[0] <=> y[0] }
  end
  
end
