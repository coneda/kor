admins = Credential.create!(name: "admins")

Kor::Tasks.reset_admin_account
Kor::Tasks.reset_guest_account

default = Collection.create! name: "Default"

Kor::Auth.grant default, :all, to: admins

Kind.create(
  name: Medium.model_name.human,
  plural_name: Medium.model_name.human(count: :other),
  uuid: Kind::MEDIA_UUID,
  settings: {
    naming: false
  }
)

SystemGroup.create(name: 'invalid')

# # TODO: still needed?
# if ENV['SAMPLE_DATA']
#   print "generating sample data ... "
#   if FactoryBot.factories.count == 0
#     require "#{Rails.root}/spec/factories"
#   end

#   media = Kind.medium_kind
#   people = FactoryBot.create :people
#   works = FactoryBot.create :works
#   FactoryBot.create(:shows,
#     from_kind_ids: [media.id],
#     to_kind_ids: [works.id]
#   )
#   FactoryBot.create(:has_created,
#     from_kind_ids: [people.id],
#     to_kind_ids: [works.id]
#   )
#   FactoryBot.create(:is_equivalent_to,
#     from_kind_ids: [works.id],
#     to_kind_ids: [works.id]
#   )
#   FactoryBot.create(:is_sibling_of,
#     from_kind_ids: [people.id],
#     to_kind_ids: [people.id]
#   )

#   leonardo = FactoryBot.create :leonardo
#   mona_lisa = FactoryBot.create :mona_lisa
#   FactoryBot.create :der_schrei
#   FactoryBot.create :landscape

#   Relationship.relate_and_save leonardo, 'has created', mona_lisa
#   puts "done"
# end
