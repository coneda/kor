module XmlHelper

  def verify_oaipmh_error(code)
    expect(response).to have_http_status(400)
    doc = Nokogiri::XML(response.body)
    doc.collect_namespaces.each{|k, v| doc.root.add_namespace k, v}
    error = doc.xpath("//xmlns:error")
    expect(doc.at_xpath("//xmlns:error/@code").value).to eq(code)
  end

  def parse_xml(xml)
    doc = Nokogiri::XML(xml)
    doc.collect_namespaces.each{|k, v| doc.root.add_namespace k, v}
    doc
  end

end