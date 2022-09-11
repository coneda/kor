admins = Credential.create!(:name => "admins")

Kor::Tasks.reset_admin_account
Kor::Tasks.reset_guest_account

default = Collection.create! :name => "Default"

Kor::Auth.grant default, :all, :to => admins

Kind.create(
  name: Medium.model_name.human,
  plural_name: Medium.model_name.human(count: :other),
  uuid: Kind::MEDIA_UUID,
  settings: {
    naming: false
  }
)

SystemGroup.create(:name => 'invalid')

