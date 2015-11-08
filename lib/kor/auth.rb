require "tmpdir"

module Kor::Auth

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
        data = Bundler.with_clean_env do
          `#{command} 2> #{dir}/error.log`
        end
        status = $?.exitstatus

        if status == 0
          return JSON.parse(data).merge(
            :parent_username => c["map_to"]
          )
        else
          error = File.read "#{dir}/error.log"
          Rails.logger.warn("AUTH script error: #{error}")
          Rails.logger.warn("AUTH script output: #{data}")
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

  def self.groups(user)
    user ||= User.guest

    user.parent.present? ? user.groups + user.parent.groups : user.groups
  end

  def self.authorized_collections(user, policies = :view)
    user ||= User.guest

    result = Grant.where(
      :credential_id => groups(user).map{|c| c.id}, 
      :policy => policies
    ).group(:collection_id).count
    
    Collection.where(:id => result.keys).to_a
  end
  
  def self.authorized?(user, policy = :view, collections = Collection.all, options = {})
    user ||= User.guest
    
    options.reverse_merge!(:required => :all)
    collections = [collections] unless collections.is_a? Array
    collections = collections.reject{|c| c.nil?}
    
    result = Grant.where(
      :credential_id => groups(user).map{|c| c.id},
      :policy => policy,
      :collection_id => collections.map{|c| c.id}
    ).group(:collection_id).count
    
    if options[:required] == :all
      result.keys.size == collections.size
    else
      result.keys.size > 0
    end
  end
  
end
