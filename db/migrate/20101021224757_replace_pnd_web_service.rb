class ReplacePndWebService < ActiveRecord::Migration
  def self.up
    Kind.all.each do |kind|
      if kind.settings['web_services']
        kind.settings['web_services'].each do |web_service|
          web_service.gsub!("pnd", "coneda_information_service")
        end
        kind.save
      end
    end
  end

  def self.down
    Kind.all.each do |kind|
      if kind.settings['web_services']
        kind.settings['web_services'].each do |web_service|
          web_service.gsub!("coneda_information_service", "pnd")
        end
      end
    end
  end
end
