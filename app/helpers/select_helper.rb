module SelectHelper

  def fields_for_select
    Kind.available_fields.map do |f|
      [f.label, f.to_s]
    end
  end

  def kinds_for_select(options = {})
    options.reverse_merge!(
      :media => false,
      :no_selection_entry => true,
      :no_selection_name => I18n.t('prompts.please_select'),
      :no_selection_value => nil
    )

    entries = Array.new
    if options[:no_selection_entry]
      entries << [ options[:no_selection_name], options[:no_selection_value] ]
    end
    entries += (options[:media] ? Kind.all : Kind.without_media).collect{|k| [k.name, k.id] }
    
    entries
  end
  
  def available_home_pages
    result = [
      ['welcome', Kor.config['app.default_home_page']],
      ['new_media', web_path(:anchor => "/entities/gallery")],
      ['expert_search', entities_path],
      ['simple_search', url_for(:controller => 'component_search', :action => 'component_search')]
    ]
    
    result.map!{|e| [I18n.t(e.first, :scope => :pages).capitalize_first_letter, e.last] }
    result.sort!{|x,y| x.first <=> y.first}
  end
  
end
