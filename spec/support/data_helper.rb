require 'factory_girl_rails'

module DataHelper
  def json
    JSON.parse response.body
  end

  def expect_collection_response(options = {})
    expect(response).to be_success

    data = json

    if options[:total].nil?
      expect(data['total']).to be >= 0
    else
      expect(data['total']).to eq(options[:total])
    end
    if options[:count]
      expect(data['records'].size).to eq(options[:count])
    end
    expect(data['page']).to be >= 1
    expect(data['per_page']).to be >= 1
    expect(data['per_page']).to be < Kor.settings['max_results_per_request']
    expect(data['records']).to be_a(Array)
    expect(data['total']).to be >= data['records'].size
  end

  def expect_created_response
    expect(response).to be_success

    data = json
    expect(data['message']).to match(/has been created/)
    expect(data['id']).to be > 0
  end

  def expect_updated_response
    expect(response).to be_success
    expect(json['message']).to match(/has been changed/)
  end

  def expect_deleted_response
    expect(response).to be_success
    expect(json['message']).to match(/has been deleted/)
  end

  def admin
    User.admin
  end

  def jdoe
    User.find_by! name: 'jdoe'
  end

  def priv
    Collection.find_by! name: 'private'
  end

  def default
    Collection.find_by! name: 'default'
  end

  def students
    Credential.find_by! name: 'students'
  end

  def admins
    Credential.find_by! name: 'admins'
  end

  def media
    Kind.medium_kind
  end

  def people
    Kind.find_by! name: 'person'
  end

  def works
    Kind.find_by! name: 'work'
  end

  def locations
    Kind.find_by! name: 'location'
  end

  def mona_lisa
    Entity.find_by! name: 'Mona Lisa'
  end

  def last_supper
    Entity.find_by! name: 'The Last Supper'
  end

  def leonardo
    Entity.find_by! name: 'Leonardo'
  end

  def paris
    Entity.find_by! name: 'Paris'
  end

  def picture_a
    Medium.find_by!(datahash: '233fcdfee7c55b3978967aacaefb9a08057607a0').entity
  end

  def picture_b
    Medium.find_by!(datahash: '517686264a2ed1a66770470525e520dac4d692ea').entity
  end

  def lecture
    AuthorityGroup.find_by! name: 'lecture'
  end

  def seminar
    AuthorityGroup.find_by! name: 'seminar'
  end

  def archive
    AuthorityGroupCategory.find_by! name: 'archive'
  end

  def nice
    UserGroup.find_by! name: 'nice'
  end

  # TODO: remove this and instead use current_user(...) from below
  # def fake_authentication(options = {})
  #   options.reverse_merge!(:persist => false)
    
  #   if options[:persist]
  #     test_data_for_auth
  #     options[:user] ||= User.admin
  #   end
    
  #   session[:user_id] = options[:user].id
  #   session[:expires_at] = Kor.session_expiry_time
  # end

  # def test_data(options = {})
  #   options.reverse_merge!(
  #     :groups => false,
  #     :config => false
  #   )
    
  #   test_data_for_auth
  #   test_kinds
  #   test_relations
  #   test_entities
    
  #   if options[:groups]
  #     FactoryGirl.create :authority_group
  #   end
  # end

  # def test_data_for_auth
  #   @admins = FactoryGirl.create :admins
  #   @main = FactoryGirl.create :default
  #   Kor::Auth.policies.each do |policy|
  #     Grant.create!(:collection => @main, :credential => @admins, :policy => policy)
  #   end
  #   @admin = FactoryGirl.create :admin, :groups => Credential.all
  # end
  
  # def test_relations
  #   FactoryGirl.create :has_created,
  #     :from_kind_id => @person_kind.id, :to_kind_id => @artwork_kind.id
  #   FactoryGirl.create :is_equivalent_to,
  #     :from_kind_id => @artwork_kind.id, :to_kind_id => @artwork_kind.id
  #   FactoryGirl.create :is_located_at,
  #     :from_kind_id => @artwork_kind.id, :to_kind_id => @location_kind.id
  #   FactoryGirl.create :shows,
  #     :from_kind_id => @medium_kind.id, :to_kind_id => @artwork_kind.id
  # end
  
  # def test_kinds
  #   @medium_kind = FactoryGirl.create :media
  #   @person_kind = FactoryGirl.create :people
  #   @artwork_kind = FactoryGirl.create :works
  #   @institution_kind = FactoryGirl.create :institutions
  #   @location_kind = FactoryGirl.create :locations
  #   @literature_kind = FactoryGirl.create :literatures
  # end

  # def test_entities  
  #   @mona_lisa = FactoryGirl.create :mona_lisa, :datings => [FactoryGirl.build(:d1533)]
  # end
  
  def default_setup(options = {})
    options.reverse_merge!(
      pictures: false,
      relationships: false
    )

    # default = Collection.find_by!(name: 'default')
    priv = Collection.create! name: 'private'

    # media = Kind.medium_kind
    people = FactoryGirl.create :people,
      fields: [
        Fields::String.new(
          name: 'gnd_id', show_label: 'GND-ID', is_identifier: true,
          show_on_entity: true
        ),
        Field.new(
          name: 'wikidata_id', show_label: 'Wikidata ID', is_identifier: true
        )
      ],
      generators: [
        Generator.new(
          name: 'gnd', directive: 'http://d-nb.info/gnd/{{entity.dataset.p227}}'
        )
      ]
    works = FactoryGirl.create :works, fields: [
      Field.new(
        name: 'wikidata_id', show_label: 'Wikidata ID', is_identifier: true
      )
    ]
    locations = Kind.create! name: 'location', plural_name: 'locations'
    institutions = Kind.create! name: 'institution', plural_name: 'institutions'

    Relation.create!(
      name: 'is located in', reverse_name: 'is location of',
      from_kind_id: works.id, to_kind_id: institutions.id
    )
    Relation.create!(
      name: 'is located in', reverse_name: 'is location of',
      from_kind_id: institutions.id, to_kind_id: locations.id
    )
    Relation.create!(
      name: 'is related to', reverse_name: 'is related to',
      from_kind_id: works.id, to_kind_id: works.id
    )
    Relation.create!(
      name: 'is related to', reverse_name: 'is related to',
      from_kind_id: works.id, to_kind_id: locations.id
    )
    FactoryGirl.create :has_created, from_kind_id: people.id, to_kind_id: works.id
    FactoryGirl.create :shows, from_kind_id: media.id, to_kind_id: works.id

    # admins = Credential.find_by! name: 'admins'
    students = FactoryGirl.create :students
    project = Credential.create! name: 'Project'

    # admin = User.find_by! name: 'admin'
    jdoe = FactoryGirl.create :jdoe, groups: [students]
    mrossi = FactoryGirl.create :mrossi, groups: [project]
    ldap = FactoryGirl.create :ldap_template
    
    Kor::Auth.grant default, :view, :to => students
    Kor::Auth.grant priv, :all, :to => admins
    Kor::Auth.grant default, :view, :to => project
    Kor::Auth.grant priv, :all, :to => project

    leonardo = FactoryGirl.create(:leonardo,
      creator_id: admin.id,
      updater_id: admin.id,
      name: 'Leonardo',
      synonyms: ['Leo'],
      datings: [
        EntityDating.new(label: 'Lebensdaten', dating_string: '1452 bis 1519')
      ],
      dataset: {
        'gnd_id' => '123456789'
      },
      properties: [{'label' => 'Epoche', 'value' => 'Renaissance'}]
    )
    mona_lisa = FactoryGirl.create(:mona_lisa,
      creator_id: admin.id,
      updater_id: admin.id,
      subtype: 'portrait',
      distinct_name: 'the real one',
      comment: 'most popular artwork in the world'
    )
    last_supper = FactoryGirl.create :the_last_supper, collection: priv, creator_id: admin.id, updater_id: admin.id
    louvre = institutions.entities.create!(collection: default, name: 'Louvre', creator_id: admin.id, updater_id: admin.id)
    paris = locations.entities.create!(collection: default, name: 'Paris', creator_id: admin.id, updater_id: admin.id)
    picture_a = FactoryGirl.create :picture_a, creator_id: admin.id, updater_id: admin.id
    picture_b = FactoryGirl.create :picture_b, collection: priv, creator_id: admin.id, updater_id: admin.id

    Relationship.relate_and_save mona_lisa, 'is related to', last_supper
    Relationship.relate_and_save mona_lisa, 'is located in', louvre
    Relationship.relate_and_save louvre, 'is located in', paris
    Relationship.relate_and_save leonardo, 'has created', mona_lisa
    Relationship.relate_and_save leonardo, 'has created', last_supper
    Relationship.relate_and_save picture_a, 'shows', mona_lisa
    Relationship.relate_and_save picture_b, 'shows', last_supper

    lecture = AuthorityGroup.create! name: 'lecture'
    archive = AuthorityGroupCategory.create! name: 'archive'
    archive.authority_groups.create! name: 'seminar'

    lecture.add_entities picture_a

    nice = UserGroup.create! user_id: jdoe.id, name: 'nice'
    nice.add_entities picture_a
  end

  # TODO: make sure this is used instead of fake_authentication
  def current_user(user)
    @current_user = user

    @current_user_mock ||= begin
      allow_any_instance_of(BaseController).to(
        receive(:current_user).and_return(@current_user)
      )

      allow_any_instance_of(BaseController).to(
        receive(:session_expired?).and_return(false)
      )

      true
    end
  end

  def self.default_setup(*args)
    dummy = Class.new
    dummy.include(self)
    dummy.new.default_setup(*args)
  end
end