require 'digest/sha2'

class User < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  serialize :login_attempts
  serialize :storage, JSON

  has_and_belongs_to_many :groups, :class_name => "Credential"
  has_many :created_entities, :class_name => 'Entity', :foreign_key => :creator_id
  has_many :updated_entities, :class_name => 'Entity', :foreign_key => :updater_id
  has_many :user_groups, :dependent => :destroy
  has_many :publishments, :dependent => :destroy

  belongs_to :parent, {
    class_name: 'User',
    foreign_key: :parent_username,
    primary_key: :name,
    autosave: false
  }
  belongs_to :personal_group, :class_name => 'Credential', :foreign_key => :credential_id
  belongs_to :personal_collection, :class_name => 'Collection', :foreign_key => :collection_id

  validates :name,
    :presence => true,
    :uniqueness => {:allow_blank => false},
    :format => {:with => /\A[a-zA-Z0-9_.@\-!:\/]+\Z/, :allow_blank => true},
    :white_space => true
  validates :email,
    :presence => true,
    :uniqueness => {:allow_blank => false},
    :format => {:with => /\A[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+[a-zA-Z]{2,4}\Z/i, :allow_blank => true},
    :white_space => true
  validates :api_key,
    :uniqueness => true,
    :length => {:minimum => 32, allow_blank: true}
  validates(:plain_password,
    format: {:allow_nil => true, :with => /\A(.{5,30})|\Z/},
    confirmation: true
  )

  validate :validate_empty_personal_collection
  validate :validate_existing_parent_user

  def validate_empty_personal_collection
    if !make_personal && personal_collection && !personal_collection.entities.empty?
        errors.add :make_personal, :personal_collection_not_empty
    end
  end

  def validate_existing_parent_user
    if self.parent_username.present? && !User.exists?(:name => self.parent_username)
        errors.add :parent_username, :user_doesnt_exist
    end
  end

  before_validation(:on => :create) do |model|
    model.generate_secrets
  end
  after_validation :set_expires_at, :create_personal, :add_personal_group

  def add_personal_group
    if self.personal_group && !self.personal_group.destroyed? && !self.groups.map{ |g| g.id }.include?(self.personal_group.id)
        self.groups << self.personal_group
    end
  end

  def create_personal
    if make_personal && !personal?
      template = Collection.joins(:owner).first

      self.personal_group = Credential.create(:name => name)
      self.personal_collection = Collection.create(:name => name)
      self.groups << self.personal_group

      if template
        template.grants.each do |grant|
          Kor::Auth.grant personal_collection, grant.policy, :to => (grant.personal? ? self.personal_group : grant.credential)
        end
      else
        Kor::Auth.grant personal_collection, :all, :to => self.personal_group
      end
    end

    if !make_personal && personal?
      self.personal_group.destroy if self.personal_group
      self.personal_collection.destroy if self.personal_collection
    end
  end

  def generate_secrets
    self.activation_hash = User.generate_activation_hash if self[:activation_hash].blank?
    self.password = User.generate_password if self[:password].blank?
    self.api_key = SecureRandom.hex(48)
  end

  def set_expires_at
    unless extension.blank?
      case extension
      when 'leave_value'
        nil
      when 'custom'
        write_attribute :expires_at, Kor.now + custom_extension.to_i.days
      when 'never'
        write_attribute :expires_at, nil
      else
        write_attribute :expires_at, Kor.now + extension.to_i.days
      end
    end
  end

  attr_accessor :extension, :custom_extension, :plain_password
  attr_writer :make_personal

  def make_personal
    if @make_personal.nil?
      personal?
    else
      @make_personal
    end
  end

  def personal?
    self.personal_group.present? && self.personal_collection.present?
  end

  def password=(value)
    self.plain_password = value
    unless value.blank?
      write_attribute :password, User.crypt(value)
    end
  end

  def display_name
    full_name.blank? ? name : full_name
  end

  def add_login_attempt
    unless self[:login_attempts]
      self[:login_attempts] = []
    end
    self[:login_attempts] << Kor.now
    self[:login_attempts].shift if self[:login_attempts].size > 3
  end

  ["", "kind_", "relation_", "authority_group_admin_"].each do |ag|
    define_method "#{ag}admin".to_sym do
      key = "#{ag}admin".to_sym
      self[key] || (
        self.parent_username.present? &&
        self.parent &&
        self.parent[key]
      )
    end

    define_method "#{ag}admin?".to_sym do
      key = "#{ag}admin".to_sym
      self[key] || (
        self.parent_username.present? &&
        self.parent &&
        self.parent[key]
      )
    end

    define_method "#{ag}admin=".to_sym do |value|
      parent_present = self.parent_username.present? && self.parent
      if parent_present && parent.send("#{ag}admin".to_sym) == !!value
        self["#{ag}admin".to_sym] = nil
      else
        super value
      end
    end
  end

  def self.guest
    if user = find_by(name: 'guest')
      user.active? ? user : nil
    end
  end

  def guest?
    name == 'guest'
  end

  def authorized_collections(policy = :view)
    Kor::Auth.authorized_collections(self, policy)
  end

  def full_auth
    group_ids = groups.pluck(:id)
    u = self
    while u = u.parent
      group_ids += u.groups.pluck(:id)
    end
    collections = {}
    scope = Grant.where(credential_id: group_ids)
    scope.group(:collection_id, :policy).count.each do |g, _count|
      collections[g.last] ||= []
      collections[g.last] << g.first
    end
    Kor::Auth.policies.each{ |p| collections[p] ||= [] }

    return {
      roles: {
        admin: admin?,
        kind_admin: kind_admin?,
        relation_admin: relation_admin?,
        authority_group_admin: authority_group_admin?
      },
      collections: collections
    }
  end

  scope :without_predefined, lambda{ where("name NOT IN (?)", ["admin", "guest"]) }
  scope :without_admin, lambda{ where("name NOT LIKE ?", "admin") }

  scope :search, lambda { |search_string|
    unless search_string.blank?
      pattern = "%#{search_string}%"
      where('name LIKE ? OR full_name LIKE ? or email LIKE ?', pattern, pattern, pattern)
    else
      all
    end
  }
  scope :logged_in_recently, lambda{
    where("last_login > ?", 30.days.ago)
  }
  scope :logged_in_last_year, lambda{
    where("last_login > ?", 1.year.ago)
  }
  scope :created_recently, lambda{
    where("created_at > ?", 30.days.ago)
  }
  scope :by_id, lambda{ |id| id.present? ? where(id: id) : all }

  def self.admin
    unless user = find_by_name('admin')
      raise "There is no admin user"
    end

    user
  end

  def self.authenticate(username, password)
    password ||= ""
    hash_candidates = [crypt(password), legacy_crypt(password)]
    where(name: username, password: hash_candidates).first
  end

  def self.pickup_session_for(id)
    id ? includes(:groups).find(id) : nil
  end

  def credential_ids
    groups.map{ |c| c.id }
  end

  def too_many_login_attempts?
    self[:login_attempts] ||= []
    self[:login_attempts].size == 3 ? self[:login_attempts].first > Kor.now - 1.hour : false
  end

  def reset_password
    self.password = User.generate_password
  end

  def self.generate_password
    User.crypt(rand.to_s)[0, 6]
  end

  def User.generate_activation_hash
    User.crypt(rand.to_s)[0, 12]
  end

  def self.legacy_crypt(value)
    Digest::SHA1.hexdigest(value)
  end

  def self.crypt(value)
    Digest::SHA2.hexdigest(value)
  end

  def fix_cryptography(password)
    if self.password == self.class.legacy_crypt(password)
      write_attribute :password, self.class.crypt(password)
    end
  end

  def active
    if self[:active] != nil
      self[:active]
    else
      if parent.present?
        parent.active
      else
        true
      end
    end
  end

  def active?
    active
  end

  def active=(value)
    if parent.present? && parent.active == !!value
      self[:active] = nil
    else
      super
    end
  end

  def inactive?
    !active?
  end

  def expires_at
    self[:expires_at] || if parent.present?
      parent[:expires_at]
    end
  end

  def expires_at=(value)
    if parent.present?
      if parent.expires_at.nil? || parent.expires_at.to_date.to_s == value
        self[:expires_at] = nil
      else
        self[:expires_at] = value
      end
    else
      self[:expires_at] = value
    end
  end

  def serializable_hash(options = {})
    super options.merge(:except => [:password, :activation_hash, :api_key])
  end

  def allowed_to?(policy = :view, collections = nil, options = {})
    Kor::Auth.allowed_to?(self, policy, collections, options)
  end
end
