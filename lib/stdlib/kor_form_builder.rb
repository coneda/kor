class Stdlib::KorFormBuilder < ActionView::Helpers::FormBuilder

  def t
    @template
  end

  def kor_submit(options = {})
    options.reverse_merge!( 
      :name => @object.new_record? ? I18n.t('verbs.create') : I18n.t('verbs.update')
    )
  
    @template.kor_submit_tag(options)
  end

  def file_field(attribute, options = {})
#    options[:style] = "color: #000000;"
    super attribute, options
  end

  def kind_selector(name, options = {}, html_options = {})
    select name, @template.kinds_for_select(options), options, html_options
  end
  
  def credential_selector(name, options = {}, html_options = {})
    select(
      name, 
      @template.options_from_collection_for_select(Credential.all, :id, :name, options[:values]), 
      options, 
      html_options
    )
  end
  
  def id_for(name)
    "#{@object_name}_#{name}"
  end
  
  def name_for(name, options = {})
    options.reverse_merge!(:array => false)
    "#{@object_name}[#{name}]" + (options[:array] ? '[]' : '')
  end
  
  # TODO this should return an array when the checkbox is selected
  def kor_select(name, items, options = {})
    options.reverse_merge!(
      :label => items.first.class.model_name.human(:count => :other),
      :multiple => false
    )
    
    if items.size > 1
      control = if options[:multiple]
        collection_select name, items, :id, :name, {}, :multiple => true
      else
        collection_select name, items, :id, :name
      end
      
      kor_input options[:label], :control => control
    else
      hidden_field name, :value => items.first.id
    end
  end
  
  def collections_selector(name, policy = :view, options = {})
    options.reverse_merge!(
      :attribute => name,
      :collections => @template.authorized_collections(policy)
    )
    
    if options[:collections].size == 1
      @template.hidden_field_tag("entity['collection_ids']", 'all')
    else
      @template.render(:partial => 'components/collections_selector', :locals => {
        :checked_collection_ids => @object.search_collection_ids,
        :collections => options[:collections],
        :name => name,
        :f => self  
      })
    end
  end

  def collection_selector(name, policy = nil, options = {})
    policy ||= @object.new_record? ? :create : :edit
    options.reverse_merge!(
      :attribute => name,
      :collections => @template.authorized_collections(policy)
    )
  
    if options[:collections].size > 1
      kor_input name, :control => collection_select(name, options[:collections], :id, :name)
    elsif options[:collections].size == 0
      ''
    else
      hidden_field name, :value => options[:collections].first.id
    end
  end
  
  def relation_selector(from_kind_id, to_kind_id)
    relation_names = Relation.available_relation_names(from_kind_id, to_kind_id)
    unless relation_names.empty?
      select :relation_name, relation_names, :selected => 
        (@object.try(:relation).try(:name) || @template.recent_relation_names.select{|rrn| relation_names.include? rrn }.first)
    else
      I18n.t("messages.no_relations_provided")
    end
  end

  def kor_input(label, options = {})
    attribute = options[:attribute] || label
    options[:control] ||= text_field(attribute)
    @template.kor_input(@object, label, options)
  end
  
  def search_field_for_dataset(config)
    control = case config.search[:type]
      when :check_box then check_box(config.name)
      when :string then text_field(config.name)
      when :text then text_area(config.name)
      when :file then file_field(config.name)
      when :select
        config[:values].unshift if config.search[:can_be_empty]
        select(config.name, config.search[:values])
      else
        raise "unrecognized form type '#{config.search[:type]}'"
    end
    
    kor_input config[:label], :control => control, :translate => false
  end

  def form_field_for_dataset(config)
    control = case config.form[:type]
      when :check_box then check_box(config.name)
      when :string then text_field(config.name)
      when :text then text_area(config.name)
      when :file then file_field(config.name)
      when :select
        config.form[:values].unshift if config.form[:can_be_empty]
        select(config.name, config.form[:values])
      else
        raise "unrecognized form type '#{config.form[:type]}'"
    end
    
    kor_input config.label, :control => control, :translate => false
  end

end
