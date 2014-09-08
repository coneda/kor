module Auth::Authentication

  def self.authenticate(username, password)
    user = User.authenticate username, password
    user ? username : nil
  end
  
  def self.authorize(username)
    User.find_by_name(username, :include => :groups) || User.create(
      :name => username
    )
  end
  
  def self.login(username, password)
    if authenticate(username, password)
      authorize(username)
    end
  end
  
end
