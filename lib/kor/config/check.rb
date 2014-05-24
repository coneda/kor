class Kor::Config::Check
  
  def initialize(to_be_checked)
    @config = to_be_checked
    check
  end
  
  def errors
    @errors ||= []
  end
  
  def valid?
    errors.empty?
  end
  
  def report(message, key = nil)
    errors << "#{message}" + (key ? " #{@config[key]}" : "")
  end
  
  def report(section, attribute, message, value = nil)
    section = Kor::Config.human_section_name(section)
    attribute = Kor::Config.human_attribute_name(attribute)
    message = I18n.t(message, :scope => "activerecord.errors.messages") if message.is_a? Symbol
    errors << "#{section}: '#{attribute}' #{message}#{value ? ' ' + value.inspect : ''}"
  end
  
  def check
    check_single_values
  end
  
  def check_single_values
    if @config['app.current_history_length'].to_i < 1
      report :app, :current_history_length, :invalid, @config['app.current_history_length']
    end
    
    if @config['app.max_file_upload_size'].to_i < 1
      report :app, :max_file_upload_size, :invalid, @config['app.max_file_upload_size']
    end
  end
  
end
