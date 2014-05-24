module ErrorHelper
  def kor_error(message)
    unless message.blank?
      content_tag 'div', h(message).capitalize_first_letter, :class => 'error'
    end
  end

  def kor_notice(message)
    unless message.blank?
      content_tag 'div', h(message).capitalize_first_letter, :class => 'notice'
    end
  end

  def announce_errors_for(object)
    if object.errors.any?
      error_box( :errors => object.errors.on_base )
    end
  end

  def deep_find_errors(object, parsed_objects = [])
    if parsed_objects.include?(object)
      return []
    else
      all_associations = if object.class.respond_to?(:reflections)
        object.class.reflections.keys
      else
        []
      end

      errors = Array.new
      validated_associations = Array.new
      object.errors.each do |attribute, message|
        if all_associations.include?(attribute.to_sym)
          validated_associations << attribute.to_s.downcase.to_sym
        else
          errors << { :object => object, :attribute => attribute, :message => message }
        end
      end

      validated_associations.each do |a|
        Array(object.send(a)).each do |associated|
          errors += deep_find_errors( associated, parsed_objects + [object] )
        end
      end

      errors.uniq
    end
  end

  def error_box(options = {})
    options.reverse_merge!(
      :header => I18n.t('activerecord.errors.template.header')
    )
    
    render :partial => 'layouts/error_box', :locals => {
      :options => options,
      :errors => deep_find_errors(options[:object])
    }
  end

end
