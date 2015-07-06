# encoding: utf-8

class UnifyWebServices < ActiveRecord::Migration
  def up
    Kind.all.each do |kind|
      kind.settings.delete :schema
      kind.settings.delete :hidden_attributes
      kind.settings.delete :suppressed_conditions
      kind.settings.delete :immutable_attributes

      (kind.settings[:web_services] || []).each do |ws|
        field = nil
        generator = nil

        case ws
          when 'ulan'
            field = Fields::String.new(:name => 'ulan', :show_label => 'ULAN-ID', :show_on_entity => false, :kind => kind)
            generator = Generator.new(
              :name => 'ulan_link', 
              :directive => "<a href='http://www.getty.edu/vow/ULANFullDisplay?find=&role=&nation=&prev_page=1&subjectid={{entity.dataset.ulan}}' target='_blank'>» ULAN</a>",
              :kind => kind
            )
          when 'wikipedia'
            generator = Generator.new(
              :name => 'wikipedia_link',
              :directive => "<a href='http://de.wikipedia.org/wiki/Spezial:Search?search={{entity.name}}' target='_blank'>» Bei Wikipedia suchen</a>",
              :kind => kind
            )
          when 'amazon'
            generator = Generator.new(:name => 'amazon_link', :directive => "<a href='http://www.amazon.com/dp/{{entity.dataset.isbn}}' target='_blank'>» Bei Amazon kaufen</a>", :kind => kind)
          when 'kvk'
            url = "http://kvk.ubka.uni-karlsruhe.de/hylib-bin/kvk/nph-kvk2.cgi"
            params = {
              :maske => "kvk-last",
              :title => "UB+Karlsruhe:+KVK+Ergebnisanzeige",
              :header => "http://www.ubka.uni-karlsruhe.de/kvk/kvk/kvk-header_de_04_07_02.html",
              :spacer => "http://www.ubka.uni-karlsruhe.de/kvk/kvk/kvk-spacer.html",
              :footer => "http://www.ubka.uni-karlsruhe.de/kvk/kvk/kvk-footer_de_04_07_02.html",
              :VERBUENDE => nil,
              :TI => nil,
              :PY => nil,
              :AU => nil,
              :CI => nil,
              :SS => nil,
              :ST => nil,
              :PU => nil,
              :sortiert => "nein",
              :css => "http://www.ubka.uni-karlsruhe.de/kvk/kvk/kvk-neu.css",
              :target => "_blank",
              :Timeout => 60
            }
            kataloge = ["SWB","BVB","NRW","HEBIS","HEBIS_RETRO","KOBV_SOLR","GBV","DDB","STABI_BERLIN","TIB"].map do |k|
              "kataloge=#{k}"
            end
            url = "#{url}?#{params.to_param}&#{kataloge.join('&')}&SB={{entity.dataset.isbn}}"
            generator = Generator.new(
              :name => 'kvk_link',
              :directive => "<a href='#{url}' target='_blank'>» KVK Katalog</a>",
              :kind => kind
            )
          when 'knd'
            unless kind.fields.where(:name => 'gnd').first
              field = Fields::String.new(:name => 'gnd', :show_label => 'GND-ID', :show_on_entity => false, :kind => kind)
            end
          when 'google_maps'
            field = Fields::String.new(:name => 'google_maps', :show_label => 'Adresse', :show_on_entity => false, :kind => kind)
            generator = Generator.new(
              :name => 'google_maps_link',
              :directive => "<a href='http://maps.google.com?q={{entity.dataset.google_maps}}' target='_blank'>» Google Maps</a>",
              :kind => kind
            )
          when 'sandrart'
            field = Fields::String.new(:name => 'sandrart', :show_label => 'Sandrart ID', :show_on_entity => false, :kind => kind)
            generator = Generator.new(
              :name => 'sandrart_person_link',
              :directive => "<a href='http://ta.sandrart.net/prs/{{entity.dataset.sandrart}}' target='_blank'>» Sandrart</a>",
              :kind => kind
            )
          when 'coneda_information_service'
            unless kind.fields.where(:name => 'gnd').first
              field = Fields::String.new(:name => 'gnd', :show_label => 'GND-ID', :show_on_entity => false, :kind => kind)
            end
          else
            raise "Web service #{ws} does not exist"
        end

        if field && field.name == "gnd"
          generator = Generator.new(
            :name => 'gnd_link',
            :directive => "<a href='http://d-nb.info/gnd/{{entity.dataset.gnd}}' target='_blank'>» Deutsche Nationalbibliothek</a>",
            :kind => kind
          )
        end

        if field && !field.save
          p field
          raise "Field could not be saved: #{field.errors.full_messages.inspect}"
        end

        if generator && !generator.save
          p generator
          raise "Generator could not be saved: #{generator.errors.full_messages.inspect}"
        end
      end

      Entity.find_each do |e|
        unless e.dataset.empty?
          new_refs = e.dataset.dup
          all_refs = e.dataset.values_at("pnd", "knd", "gnd")
          all_filtered = all_refs.select{|e| e.present?}
          value = all_filtered.last.presence
          new_refs.delete "pnd"
          new_refs.delete "knd"
          if value.present?
            new_refs["gnd"] = value
          else
            new_refs.delete "gnd"
          end

          if new_refs != e.dataset
            e.dataset = new_refs
            e.update_column :attachment, JSON.dump(e.attachment)
          end
        end
      end

      kind.settings.delete :web_services
      kind.update_column :settings, YAML.dump(kind.settings)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
