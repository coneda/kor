administrators = Credential.create!(:name => "admins")

Kor::Tasks.reset_admin_account
Kor::Tasks.reset_guest_account

default = Collection.create! :name => "Default"

Kor::Auth.policies.each do |policy|
  Grant.create! :collection => default, :policy => policy, :credential => administrators
end

Kind.create(
  name: Medium.model_name.human,
  plural_name: Medium.model_name.human(count: :other),
  uuid: Kind::MEDIA_UUID,
  settings: {
    naming: false
  }
)

SystemGroup.create(:name => 'invalid')

if ENV['SAMPLE_DATA']
  print "generating sample data ... "
  if FactoryGirl.factories.count == 0
    require "#{Rails.root}/spec/factories"
  end

  media = Kind.medium_kind
  people = FactoryGirl.create :people
  works = FactoryGirl.create :works
  FactoryGirl.create(:shows,
    from_kind_ids: [media.id],
    to_kind_ids: [works.id]
  )
  FactoryGirl.create(:has_created,
    from_kind_ids: [people.id],
    to_kind_ids: [works.id]
  )
  FactoryGirl.create(:is_equivalent_to,
    from_kind_ids: [works.id],
    to_kind_ids: [works.id]
  )
  FactoryGirl.create(:is_sibling_of,
    from_kind_ids: [people.id],
    to_kind_ids: [people.id]
  )

  leonardo = FactoryGirl.create :leonardo
  mona_lisa = FactoryGirl.create :mona_lisa
  FactoryGirl.create :der_schrei
  FactoryGirl.create :landscape

  Relationship.relate_and_save leonardo, 'has created', mona_lisa
  puts "done"
end
