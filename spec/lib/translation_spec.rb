require "rails_helper"

RSpec.describe "translations" do

  it "should have full translations for all supported locales" do
    base = YAML.load_file("#{Rails.root}/config/locales/en.yml")["en"]
    stack = []

    comparator = Proc.new do |base, locale, test|
      case base
        when String then expect(test).to be_a(String), "expected #{stack.inspect} to be a string"
        when Hash
          # binding.pry unless test.is_a?(Hash)
          expect(test).to be_a(Hash), "#{locale}: expected #{stack.inspect} to be a Hash, but its not"
          base.each do |k, v| 
            stack.push k
            comparator.call(v, locale, test[k])
            stack.pop
          end
      end
    end

    (I18n.available_locales - [:en]).each do |locale|
      translation = YAML.load_file("#{Rails.root}/config/locales/#{locale}.yml")[locale.to_s]
      comparator.call(base, locale, translation)
    end
  end

end