class WebServices::AmazonLink < WebServices::Link

  def self.link_for(entity)
    unless entity.dataset['isbn'].blank?
      "http://www.amazon.com/gp/product/#{entity.dataset['isbn']}"
    end
  end
  
end
