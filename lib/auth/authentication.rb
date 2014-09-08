module Auth::Authentication

  def self.authenticate(username, password)
    user = User.authenticate username, password
    return true if user

    (Kor.config["auth.sources"] || []).each do |method, c|
      data = `KOR_USERNAME=#{username} KOR_PASSWORD=#{password} #{c["script"]}`
      status = $?.exitstatus
      if status == 0
        return JSON.parse(data).merge(
          :parent_username => c["map_to"]
        )
      end
    end

    false
  end
  
  def self.authorize(username, additional_attributes = true)
    user = User.find_by_name(username, :include => :groups) || User.new(
      :name => username
    )

    if additional_attributes.is_a?(Hash)
      user.update_attributes additional_attributes
    else
      user.save
    end

    user
  end
  
  def self.login(username, password)
    if attributes = authenticate(username, password)
      authorize(username, attributes)
    end
  end
  
end
