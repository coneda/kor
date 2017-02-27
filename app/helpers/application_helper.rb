module ApplicationHelper

  def kor_entity(entity, options = {})
    options.reverse_merge!(
      include_kind: false,
      include_content_type: true,
      short: false,
      how_short: 30,
      link: true,
      url: web_path(:anchor => entity_path(entity)),
      style: :icon,
      buttons: true
    )

    entity = Entity.find_by_id(entity) unless entity.is_a?(Entity)
    name = h(entity.display_name)
    
    render :partial => 'layouts/kor_entity', :locals => {
      entity: entity,
      name: name,
      options: options
    }
  end

  def kor_paginate(query_result)
    if query_result.needs_pagination?
      result = I18n.t('goto', :where => I18n.t('nouns.page', :count => 1))
      result += link_to kor_command_image('pager_left') unless query_result.first_page?
      pages = options_for_select((1..query_result.total_pages), query_result.page)
      result += select_tag("#{(rand * 10000).round}_pagination", pages, :id => nil)
      result += I18n.t 'of', :amount => query_result.total_pages
      result += link_to kor_command_image('pager_right') unless query_result.last_page?
      "<div class='pagination'>#{result}</div>".html_safe
    end
  end
  
  def row_identifiers_for(model)
    klass = model.class.to_s.underscore
    {:class => klass, :id => "#{klass}_#{model.id}"}
  end

  def version_info(options = {})
    options.reverse_merge!(:newline => false)
    
    render :partial => 'layouts/version_info', :locals => {:newline => options[:newline]}
  end

  # def authorized?(policy = :view, collections = Collection.all, options = {})
  #   options.reverse_merge!(:required => :any)
  
  #   Kor::Auth.allowed_to? current_user, policy, collections, options
  # end
  
  def authorized_collections(policy = :view)
    Kor::Auth.authorized_collections current_user, policy
  end
  
  def kor_translate(item)
    case item
      when TrueClass then I18n.t('yes')
      when FalseClass then I18n.t('no')
      else
        I18n.t('nil')
    end
  end

  def sort_link_to(label, criterium)
    if params[:sort_by] == criterium
      if params[:sort_order] == 'ASC'
        link_to label, :sort_by => criterium, :sort_order => 'DESC'
      else
        link_to label, :sort_by => criterium, :sort_order => 'ASC'
      end
    else
      link_to label, :sort_by => criterium, :sort_order => 'ASC'
    end
  end

  def authorized_collections(policy = :view)
    Kor::Auth.authorized_collections current_user, policy
  end

  def kor_sort(array, criterium = :name)
    array.sort{|x,y| x.send(criterium) <=> y.send(criterium) }
  end
  
  def kor_command_image(name, options = {})
    options.reverse_merge!(
      :extension => 'gif',
      :title => I18n.t(name, :scope => :title_verbs)
    )
    
    path = "#{name}.#{options[:extension]}"
    path_hover = "#{name}_over.#{options[:extension]}"
    options.delete :extension
    image_tag(path, options.merge(
      'class' => 'kor_command_image',
      'data-name' => name,
      'data-normal-url' => image_path(path),
      'data-hover-url' => image_path(path_hover)
    ))
  end

  # returns a hash which contains all the routing information
  def routing_from_url(url)
    url = url_for(url)
    Rails.application.routes.recognize_path url
  end

  # TODO: remove the translation logic from the helper or refactor in another manner
  # returns an item to be included in the navigation bar. it takes care of
  # the highlighting of active items by assigning them the 'active_item' class
  def navigation_item( label, target, options = {} )
    options.reverse_merge!(
      :only => nil,
      :except => nil,
      :highlight => :action
    )

    current_controller = controller.controller_name
    current_action = controller.action_name
    link_controller = routing_from_url(target)[:controller]
    link_action = routing_from_url(target)[:action]
    
    active = current_controller == link_controller
    active &= (current_action == link_action) if options[:highlight] == :action
    active &= !(Array(options[:except]).include? current_action.to_sym)
    active &= (Array(options[:only]).include? current_action.to_sym) if options[:only]

    content_tag 'li', :class => (active ? 'active_item' : 'inactive_item') do
      link_to label.capitalize_first_letter, target
    end
  end
  
  def submenu_section(&block)
    content = capture(&block).strip.html_safe
    result = content_tag('li', nil, :class => 'small_spacer') + content
    unless content.empty?
      result.html_safe
    end
  end

  def reset_tag(value = I18n.t('verbs.reset'))
    "<input value=\"#{value}\" type=\"reset\">"
  end

  def section_panel(options = {}, &block)
    options.reverse_merge!(
      title: '',
      capitalize_title: true,
      subtitle: '',
      capitalize_subtitle: true,
      commands: '',
      content: block_given? ? capture(&block) : nil,
      switch: false
    )
    
    if options[:subtitle]
      options[:subtitle] = options[:subtitle].capitalize_first_letter if options[:capitalize_subtitle]
    end
    
    render :partial => 'layouts/section_panel', :locals => {:options => options}
  end
  
  def registration_notice
    I18n.t('registration_notice', :default => "").html_safe
  end
  
  def help_for(controller, action)
    result = Kor.config["help.#{controller.gsub('/', '.')}.#{action}"] || ""
    result.gsub!("\n\n", '<br /><br />')
    result.gsub!("\r\n\r\n", '<br /><br />')
    result.html_safe
  end

  def custom_styles
    filename = File.expand_path(Kor.config['custom_css_file'])
    if filename and File.exists?(filename)
      public_path = "#{Rails.root}/public/custom.css"
      unless File.exists?(public_path)
        system "ln -sfn #{filename} #{public_path}"
      end
      stylesheet_link_tag '/custom', media: 'screen'
    end
  end

  def any_env_auth?
    Kor::Auth.env_sources.present?
  end

end
