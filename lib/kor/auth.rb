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

  def self.var_to_array(value)
    value.present? ? value.split(/\s+/) : []
  end

  def self.env_login(env)
    Rails.logger.info "environment auth with env: #{env.inspect}"

    env_sources.each do |key, source|
      var_to_array(source['user']).each do |ku|
        if username = env[ku]
          Rails.logger.info "found username #{username}"

          mail_candidates = 
            var_to_array(source['mail']).
              map{|km| env[km]}.
              select{|e| e.present?} +
            var_to_array(source['domain']).
              map{|d| "#{username}@#{d}"}

          if mail_candidates.empty?
            Rails.logger.info "no valid mail address found"
          else
            Rails.logger.info "found mail addresses: #{mail_candidates.inspect}"
            
            mail_candidates.each do |mail|
              full_name = nil
              var_to_array(source['full_name']).each do |kf|
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
    (sources || {}).select do |key, source|
      type = source['type'] || 'script'
      type == 'script'
    end
  end

  def self.env_sources
    (sources || {}).select do |key, source|
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

        if Kor.settings['fail_on_update_errors']
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

  def self.authorized_collections(user, policies = :view, options = {})
    user ||= User.guest
    policies ||= :view
    policies = [policies] unless policies.is_a?(Array)

    options[:cache] ||= {}
    options[:cache][:data] ||= user.full_auth

    result_ids = nil
    policies.each do |p|
      cids = options[:cache][:data][:collections][p.to_s]
      result_ids ||= cids
      result_ids &= cids
    end
    Collection.where(id: result_ids)
  end

  # def self.authorized_credentials(collection, policy = :view)
  #   collection.grants.where(policy: policy).map do |grant|
  #     grant.credential
  #   end
  # end

  def self.to_ids(objects)
    case objects
    when ActiveRecord::Base then [objects.id]
    when Integer then [objects]
    when Array, ActiveRecord::Relation
        objects.map do |o|
          o.respond_to?(:id) ? o.id : o
        end
      else
        raise "can't handle #{objects.inspect}"
    end
  end
  
  def self.allowed_to?(user, policy = :view, collections = nil, options = {})
    options.reverse_merge!(:required => :all)
    collections ||= Collection.all.to_a
    user ||= User.guest
    policy = self.policies if policy == :all
    policy = [policy] unless policy.is_a?(Array)
    collection_ids = to_ids(collections)

    options[:cache] ||= {}
    options[:cache][:data] ||= user.full_auth

    m = (options[:required] == :all ? :all? : :any?)
    collection_ids.send(m) do |cid|
      policy.all? do |p|
        ids = options[:cache][:data][:collections][p.to_s]
        ids.nil? ? false : ids.include?(cid)
      end
    end
  end

  def self.authorized_for_relationship?(user, relationship, policy = :view)
    if relationship.to && relationship.from
      case policy
      when :view
          view_from = allowed_to?(user, :view, relationship.from.collection)
          view_to = allowed_to?(user, :view, relationship.to.collection)
          
          view_from and view_to
      when :create, :delete, :edit
          view_from = allowed_to?(user, :view, relationship.from.collection)
          view_to = allowed_to?(user, :view, relationship.to.collection)
          edit_from = allowed_to?(user, :edit, relationship.from.collection)
          edit_to = allowed_to?(user, :edit, relationship.to.collection)
          
          (view_from and edit_to) or (edit_from and view_to)
        else
          false
      end
    else
      true
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

  def self.sources(refresh = false)
    @sources = nil if refresh

    @sources ||= begin
      {}.tap do |results|
        ENV.each do |key, value|
          if m = key.match(/^AUTH_SOURCE_([A-Z]+)_([A-Z_]+)$/)
            results[m[1].downcase] ||= {}
            results[m[1].downcase][m[2].downcase] = value
          end
        end
      end
    end
  end
end
