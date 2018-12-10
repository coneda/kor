class UserGroup < EntityGroup
  has_and_belongs_to_many :entities
  belongs_to :owner, class_name: 'User', foreign_key: :user_id

  validates(:name,
    uniqueness: { :scope => :user_id },
    format: {
      :with => /\A[^\s]{,30}(\s[^\s]{,30})*\Z/, :message => :invalid_words
    }
  )
  validates :user_id, presence: true

  scope :owned_by, lambda { |user| where(:user_id => user ? user.id : nil) }
  scope :shared, lambda { where(:shared => true) }
  scope :latest_first, lambda { order('created_at DESC') }
  scope :containing, lambda { |entity_ids|
    joins('JOIN entities_user_groups ge on user_groups.id = ge.user_group_id').
      where('ge.entity_id' => entity_ids)
  }
end
