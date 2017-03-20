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

      script_sources.each do |method, c|
        command = "bash -c \"#{c["script"]}\""
        status = Bundler.with_clean_env do
          system(
            {
              "KOR_USERNAME_FILE" => "#{dir}/username.txt",
              "KOR_PASSWORD_FILE" => "#{dir}/password.txt",
              "KOR_USERNAME" => username,
              "KOR_PASSWORD" => password
            },
            "#{command} > #{dir}/stdout.log 2> #{dir}/error.log"
          )
        end
        data = File.read("#{dir}/stdout.log")

        if status
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

  def self.env_login(env)
    Rails.logger.info "environment auth with env: #{env.inspect}"

    env_sources.each do |key, source|
      source['user'].each do |ku|
        if username = env[ku]
          Rails.logger.info "found username #{username}"

          mail_candidates = 
            (source['mail'] || []).
              map{|km| env[km]}.
              select{|e| e.present?} +
            (source['domain'] || []).
              map{|d| "#{username}@#{d}"}

          if mail_candidates.empty?
            Rails.logger.info "no valid mail address found"
          else
            Rails.logger.info "found mail addresses: #{mail_candidates.inspect}"
            
            mail_candidates.each do |mail|
              full_name = nil
              source['full_name'].each do |kf|
                full_name ||= env[kf]
              end

              if s = source['splitter']
                username = username.split(Regexp.new(s)).first
                mail = mail.split(Regexp.new(s)).first
                full_name = full_name.split(Regexp.new(s)).first if full_name
              end
              
              data = {
                parent_username: source['map_to'],
                email: mail,
                full_name: full_name
              }

              Rails.logger.info "authorizing user #{username} with data #{data.inspect}"
              return authorize(username, data)
            end
          end
        else
          Rails.logger.info "no username found"
          false
        end
      end
    end

    false
  end

  def self.script_sources
    (config['sources'] || []).select do |key, source|
      type = source['type'] || 'script'
      type == 'script'
    end
  end

  def self.env_sources
    (config['sources'] || []).select do |key, source|
      source['type'] == 'env'
    end
  end

  def self.authorize(username, additional_attributes = true)
    user = User.includes(:groups).find_or_initialize_by(:name => username)

    if additional_attributes.is_a?(Hash)
      user.assign_attributes additional_attributes
    end

    if user.save
      user
    else
      if user.new_record?
        Rails.logger.info "user couldn't be created: #{user.errors.full_messages.inspect}"
        nil
      else
        Rails.logger.info "user couldn't be updated: #{user.errors.full_messages.inspect}"

        if config['fail_on_update_errors']
          Rails.logger.info "authentication failed due to update errors"
          nil
        else
          Rails.logger.info "allowing authentication despite update errors"
          user
        end
      end
    end
  end
  
  def self.login(username, password)
    if attributes = authenticate(username, password)
      authorize(username, attributes)
    end
  end

  def self.groups(user)
    if user ||= User.guest
      user.parent.present? ? user.groups + user.parent.groups : user.groups
    else
      []
    end
  end

  def self.authorized_collections(user, policies = :view)
    user ||= User.guest

    result = Grant.where(
      :credential_id => groups(user).map{|c| c.id}, 
      :policy => policies
    ).group(:collection_id).count

    Collection.where(:id => result.keys).to_a
  end

  def self.authorized_credentials(collection, policy = :view)
    collection.grants.where(policy: policy).map do |grant|
      grant.credential
    end
  end
  
  def self.allowed_to?(user, policy = :view, collections = nil, options = {})
    collections ||= Collection.all.to_a
    user ||= User.guest
    policy = self.policies if policy == :all
    
    options.reverse_merge!(:required => :all)
    collections = if collections.is_a?(Collection)
      [collections]
    else
      collections.to_a
    end
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

  def self.grant(collection, policies, options = {})
    policies = case policies
      when :all then self.policies
      when Symbol then [policies]
      when String then [policies]
      else
        policies
    end

    options[:to] = case options[:to]
      when nil then []
      when Credential then [options[:to]]
      else
        options[:to]
    end
  
    policies.each do |policy|
      options[:to].each do |credential|
        collection.grants << Grant.new(policy: policy, credential: credential)
      end
    end
  end

  def self.revoke(collection, policies, options = {})
    policies = case policies
      when :all then self.policies
      when Symbol then [policies]
      when String then [policies]
      else
        policies
    end

    options[:from] = case options[:from]
      when nil then []
      when Credential then [options[:from]]
      else
        options[:from]
    end

    collection.grants.
      with_policy(policies).
      with_credential(options[:from]).
      destroy_all
  end

  def self.policies
    ['view', 'edit', 'create', 'delete', 'download_originals', 'tagging', 'view_meta']
  end

  def self.config
    @config ||= Kor.config['auth']
  end

end
