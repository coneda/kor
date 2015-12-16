Kor.config['maintainer.email'] = 'admin@localhost'

administrators = Credential.create!(:name => "Administrators")

User.create!(
  :name => "admin",
  :full_name => I18n.t('users.administrator'),
  :groups => [ administrators ],
  :password => 'admin', 
  :email => Kor.config['maintainer.mail'],
  :terms_accepted => true,
  
  :admin => true,
  :relation_admin => true,
  :authority_group_admin => true,
  :user_admin => true,
  :credential_admin => true,
  :collection_admin => true,
  :kind_admin => true,
  :developer => false
)

User.create!(
  :name => "guest",
  :full_name => "Guest",
  :email => "guest@example.com",
  :terms_accepted => true
)

default = Collection.create! :name => "Default"

default.policies.each do |policy|
  Grant.create! :collection => default, :policy => policy, :credential => administrators
end

Kind.create(:name => Medium.model_name.human, :plural_name => Medium.model_name.human(:count => :other),
  :settings => {
    :naming => false
  }
)

SystemGroup.create(:name => 'invalid')