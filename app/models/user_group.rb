class UserGroup < EntityGroup
  has_and_belongs_to_many :entities do
    def only(kind)
      kind_id = Array(kind).collect{|k| k.is_a?(Kind) ? k.id : k }
      is_a(kind_id).alphabetically
    end
    
    def images
      only(Kind.medium_kind)
    end
    
    def without_images
      except(Kind.medium_kind)
    end
  end
  belongs_to :owner, :class_name => 'User', :foreign_key => :user_id
  
  validates_uniqueness_of :name, :scope => :user_id
  validates_format_of :name, :with => /\A[^\s]{,30}(\s[^\s]{,30})*\Z/, :message => :invalid_words
  validates_presence_of :user_id
  
  scope :owned_by, lambda { |user| where(:user_id => user ? user.id : nil) }
  scope :shared, where(:shared => true)
  scope :named_like, lambda { |name| where("name LIKE ?", "%#{name}%") }
  scope :latest_first, order('created_at DESC')
end
