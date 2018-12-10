module XmlHelper
  def verify_oaipmh_error(code)
    expect(response).to have_http_status(400)
    doc = Nokogiri::XML(response.body)
    doc.collect_namespaces.each { |k, v| doc.root.add_namespace k, v }
    error = doc.xpath("//xmlns:error")
    expect(doc.at_xpath("//xmlns:error/@code").value).to eq(code)
  end

  def parse_xml(xml)
    doc = Nokogiri::XML(xml)
    doc.collect_namespaces.each { |k, v| doc.root.add_namespace k, v }
    doc
  end

  def self.compile_validator
    engine = ERB.new(File.read "#{Rails.root}/spec/fixtures/oai_pmh_validator.xsd.erb")
    system "mkdir -p #{Rails.root}/tmp"
    File.open "#{Rails.root}/tmp/oai_pmh_validator.xsd", 'w' do |f|
      f.write engine.result(binding)
    end
  end
end
