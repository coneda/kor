require "tmpdir"

module Auth::Authentication

  def self.authenticate(username, password)
    user = User.authenticate username, password
    return true if user

    Dir.mktmpdir do |dir|
      File.open "#{dir}/username.txt", "w" do |f|
        f.write username
      end
      File.open "#{dir}/password.txt", "w" do |f|
        f.write password
      end

      (Kor.config["auth.sources"] || []).each do |method, c|
        command = "bash -c \"KOR_USERNAME_FILE=#{dir}/username.txt KOR_PASSWORD_FILE=#{dir}/password.txt #{c["script"]}\""
        data = `#{command} 2> /dev/null`
        status = $?.exitstatus
        if status == 0
          return JSON.parse(data).merge(
            :parent_username => c["map_to"]
          )
        end
      end
    end

    false
  end
  
  def self.authorize(username, additional_attributes = true)
    user = User.find_by_name(username, :include => :groups) || User.new(
      :name => username
    )

    if additional_attributes.is_a?(Hash)
      user.assign_attributes additional_attributes
    end

    if user.save
      user
    else
      nil
    end
  end
  
  def self.login(username, password)
    if attributes = authenticate(username, password)
      authorize(username, attributes)
    end
  end
  
end
