module KindsHelper

  def web_services_for_select
    WebServices::Dispacher.web_services.map{|ws| [ ws.label, ws.name ]}
  end
  
end
