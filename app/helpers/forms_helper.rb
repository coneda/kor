module FormsHelper

  def back_link_tag(options = {})
    button_to_function I18n.t('back'), 'window.location.href = \'' + back_save + '\''
  end

  def kor_submit_tag(options = {})
    options.reverse_merge!(
      :div => true,
      :name => I18n.t('verbs.send'),
      :class => 'submit'
    )

    if options[:div]
      content_tag 'div class="kor_submit"', submit_tag(options[:name].capitalize_first_letter, options), :class => 'submit'
    else
      submit_tag(options[:name].capitalize_first_letter, options)
    end
  end

  def kor_reset_tag(options = {})
    options.reverse_merge!(
      :onmouseover => "$(this).addClass('highlighted_button')",
      :onmouseout => "$(this).removeClass('highlighted_button')",
      :div => true,
      :name => I18n.t('verbs.reset'),
      :class => 'reset'
    )

    if options[:div]
      options.delete :div
      content_tag 'div', submit_tag(options[:name].capitalize_first_letter, options), :class => 'reset'
    else
      submit_tag(options[:name].capitalize_first_letter, options)
    end
  end


  def collection_selector_tag(name, options = {})
    options.reverse_merge!(
      :label => name,
      :policy => :view,
      :html => {}
    )
    options[:collections] ||= authorized_collections(options[:policy])

    if options[:collections].size == 1
      hidden_field_tag name, (params[name] || options[:collections].first.id)
    else
      selected = params[name] || current_user.default_collection_id.to_i
      os = options_from_collection_for_select(options[:collections], :id, :name, selected)
      kor_input_tag options[:label], :class => Entity, :control => select_tag(name, os, options[:html])
    end
  end

  def collections_selector_tag(name, search_collection_ids, options = {})
    options.reverse_merge!(
      :attribute => name,
      :collections => authorized_collections(:view)
    )

    if options[:collections].size == 1
      hidden_field_tag name, options[:collections].first.id
    else
      render(:partial => 'components/collections_selector', :locals => {
        :checked_collection_ids => search_collection_ids,
        :collections => options[:collections],
        :name => name
      })
    end
  end

  def credentials_selector_tag(attribute, options = {})
    options.reverse_merge(
      :selected => nil,
      :replace => false
    )

    credentials = Credential.non_personal

    if options[:collection]
      grants = options[:collection].grants_by_policy[options[:policy]]
      if grants
        options[:selected] = grants.map do |grant|
          grant.credential_id
        end
      end

      if options[:collection].owner && !credentials.include?(options[:collection].owner.personal_group)
        credentials << options[:collection].owner.personal_group
      end
    end

    option_tags = options_from_collection_for_select(credentials, :id, (options[:replace] ? :filtered_name : :name), options[:selected])
    select_tag attribute, option_tags, :multiple => true
  end

  def relation_selector_tag(attribute, options = {}, html_options = {})
    selectable_options = []
    options[:selected] ||= nil
    if options[:from_id] && options[:to_id]
      from_kind_id = Entity.find(options[:from_id]).try(:kind).try(:id)
      to_kind_id = Entity.find(options[:to_id]).try(:kind).try(:id)
      selectable_options = Relation.available_relation_names(
        from_ids: from_kind_id,
        to_ids: to_kind_id
      )
    else
      selectable_options = Relation.available_relation_names
    end

    select_tag attribute,
      options_for_select(selectable_options, options[:selected]),
      html_options
  end

  def kor_input_tag(label, options = {})
    attribute = options[:attribute] || label
    control = options[:control] || text_field_tag(attribute)

    if options[:translate] != false && options[:class]
      label = options[:class].human_attribute_name(label.to_s)
    end

    label = label.to_s if label.is_a? Symbol
    label = label.capitalize_first_letter unless options[:no_cap]

    content_tag 'div', :class => 'form_field' do
      content_tag 'ul' do
        content_tag('li', label.html_safe) + content_tag('li', control)
      end
    end
  end

  def kor_input(object, label, options = {})
    object_name = object.class.name.underscore
    attribute = options[:attribute] || label
    options[:control] ||= text_field(object_name, attribute)
    options[:class] ||= object.class

    kor_input_tag( label, options )
  end

  def kind_selector_tag(name, options = {})
    select_tag name, options_for_select(kinds_for_select(options), options[:selected].to_i), options
  end

  def search_fields_for_entity_dataset(query)
    unless query.kind_id.blank?
      result = Kind.find(query.kind_id).field_instances(query).map do |field|
        begin
          render :partial => field.class.search_partial_name, :locals => {:field => field}
        rescue ActionView::MissingTemplate => e
          render :partial => 'fields/search/base', :locals => {:field => field}
        end
      end

      result.join
    end
  end

  def form_fields_for_entity_dataset(entity)
    if entity.kind_id && !entity.kind.fields.empty?
      result = entity.kind.field_instances(entity).map do |field|
        begin
          render :partial => field.class.form_partial_name, :locals => {:field => field}
        rescue ActionView::MissingTemplate => e
          render :partial => 'fields/form/base', :locals => {:field => field}
        end
      end

      result.join
    end
  end

  def form_fields_for_entity_synonym(synonym = nil)
    text_field_tag('entity[synonyms][]', synonym)
  end

  def form_fields_for_entity_property(property = nil, options = {} )
    property ||= {}

    kor_input_tag(I18n.t('nouns.label', :count => 1), :control => text_field_tag('entity[properties][][label]', property['label'])) +
    kor_input_tag(I18n.t('nouns.value', :count => 1), :control => text_field_tag('entity[properties][][value]', property['value']))
  end

  def form_fields_for_entity_dating(entity_dating = nil)
    prefix = "new"
    label = @entity.kind.dating_label

    if entity_dating && !entity_dating.new_record?
      prefix = "existing"
      label = entity_dating.label
    end
    entity_dating ||= EntityDating.new

    fields_for "entity[#{prefix}_datings_attributes][]", entity_dating, :builder => Kor::FormBuilder do |ed|
      ed.hidden_field(:lock_version).html_safe +
      ed.kor_input(:label, :control => ed.text_field(:label, :value => label)).html_safe +
      ed.kor_input(:dating_string).html_safe
    end
  end

  def form_fields_for_relationship_property(property = nil)
    content_tag 'div', :class => 'property' do
      text_field_tag 'relationship[properties][]', (defined?(property) ? property : nil)
    end
  end

  def remote_attachments(id, title, remote_options, &block)
    render :partial => 'layouts/remote_attachments', :locals => {
      :id => id,
      :title => title,
      :remote_options => remote_options,
      :content => capture(&block)
    }
  end

  def attachments(id, title, template, &block)
    content_for :templates, content_tag('div', attachment(template), :class => 'attachment_' + id)

    render :partial => 'layouts/attachments', :locals => {
      :id => id,
      :title => title,
      :template => template,
      :content => capture(&block)
    }
  end

  def attachment(content = nil, &block)
    b = content
    b = capture(&block) if block_given?

    render :partial => 'layouts/attachment', :locals => {
      :content => b,
    }
  end

end
