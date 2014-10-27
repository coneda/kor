module Kernel
  def ArgumentArray(value)
    value.is_a?(Array) ? value : [value]
  end
end

module DelayedPaperclip
  module InstanceMethods
    def enqueue_delayed_processing
      mark_enqueue_delayed_processing
      (@_enqued_for_processing || []).each do |name|
        enqueue_post_processing_for(name) if self.send(name).file?
      end
      @_enqued_for_processing_with_processing = []
      @_enqued_for_processing = []
    end
  end
end

module Faker
  class Base
    class << self
      def fetch(key)
        old_available_locales = I18n.available_locales
        old_locale = I18n.locale
        I18n.available_locales += [:en]
        I18n.locale = :en
        result = I18n.translate("faker.#{key}").rand
        I18n.locale = old_locale
        I18n.available_locales = old_available_locales
        result
      end
    end
  end
end
