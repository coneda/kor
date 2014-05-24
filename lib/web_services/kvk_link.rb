class WebServices::KvkLink < WebServices::Link

  def self.label
    "KVK"
  end

  def self.link_for(entity)
    isbn = entity.dataset['isbn']
  
    unless isbn.blank?
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
        :SB => isbn,
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
      
      return "#{url}?#{params.to_param}&#{kataloge.join('&')}"
    end
    
    return nil
  end
  
end

