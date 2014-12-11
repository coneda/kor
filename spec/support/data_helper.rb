# encoding: utf-8

module DataHelper

  def test_data(options = {})
    options.reverse_merge!(
      :groups => false,
      :config => false
    )
    
    test_data_for_auth
    test_kinds
    test_relations
    test_entities
    
    if options[:groups]
      test_authority_groups
      test_authority_group_categories
    end
  end

  def test_data_for_auth
    @admins = Credential.make :name => 'Administratoren'
    @main = Collection.make
    @main.policies.each do |policy|
      Grant.create(:collection => @main, :credential => @admins, :policy => policy)
    end
    @admin = User.make :admin, :groups => Credential.all
  end
  
  def test_relations
    Relation.make(:name => "hat erschaffen", :reverse_name => 'wurde erschaffen von', 
      :from_kind_ids => [ @person_kind.id ], :to_kind_ids => [ @artwork_kind.id ])
    @is_equivalent_to = Relation.make(:name => "ist äquivalent zu", :reverse_name => 'ist äquivalent zu', 
      :from_kind_ids => [ @artwork_kind.id ], :to_kind_ids => [ @artwork_kind.id ])
    Relation.make(:name => "befindet sich in", :reverse_name => 'ist Ort von', 
      :from_kind_ids => [ @artwork_kind.id ], :to_kind_ids => [ @location_kind.id ])
    Relation.make(:name => "stellt dar", :reverse_name => 'wird dargestellt von', 
      :from_kind_ids => [ @medium_kind.id ], :to_kind_ids => [ @artwork_kind.id ])
  end
  
  def test_kinds
    @medium_kind = Kind.create!(:name => Medium.model_name.human, :plural_name => Medium.model_name.human(:count => :other),
      :settings => {
        :naming => false
      }
    )
    @person_kind = Kind.make(:name => "Person")
    @artwork_kind = Kind.make(:name => "Werk", :plural_name => 'Werke')
    @institution_kind = Kind.make(:name => "Institution")
    @location_kind = Kind.make(:name => "Ort")
    @literature_kind = Kind.make(:name => "Literatur")
  end

  def test_entities  
    kind = Kind.find_by_name('Werk')
  
    @mona_lisa = Entity.make(:name => 'Mona Lisa',
      :collection => @main,
      :kind => kind,
      :datings => [ EntityDating.new(
        :label => 'Datierung',
        :dating_string => '1533'
      )],
      :dataset => {
        :gnd => '12345'
      }
    )
    
    @monalisa = Entity.make(:name => 'Monalisa', 
      :collection => @main,
      :kind => kind,
      :datings => [EntityDating.new(
        :label => 'Datierung',
        :dating_string => '1533'
      )],
      :dataset => {
        :gnd => '123456',
        :google_maps => 'Deutsche Straße 12, Frankfurt'
      }
    )
  end
  
  def test_authority_groups
    AuthorityGroup.make(:name => 'Sander')
  end
  
  def test_authority_group_categories
    AuthorityGroupCategory.make(:name => "Vorlesungen")
    AuthorityGroupCategory.make(:name => "Exkursionen")
  end
  
  
  # Mocks
  
  def mock_medium_kind
    unless @medium_kind
      @medium_kind = mock_model(Kind,
        :name => 'Abbildung', 
        :dataset_class => 'Medium'
      )
      
      Kind.stub(:medium_kind).and_return(@medium_kind)
    end
    
    @medium_kind
  end
  
  # authorized collections
  def side_collection
    @side_collection ||= Collection.make(:name => 'Side Collection')
  end
  
  def side_entity(attributes = {})
    @side_entity ||= @person_kind.entities.make attributes.reverse_merge(
      :collection => side_collection, 
      :name => 'Leonardo da Vinci'
    )
  end
  
  def main_entity(attributes = {})
    @main_entity ||= @artwork_kind.entities.make attributes.reverse_merge(
      :collection => @main, 
      :name => 'Mona Lisa'
    )
  end
  
  def set_side_collection_policies(policies = {})
    policies.each do |p, c|
      side_collection.policy_groups[p] = c
    end
    
    side_collection.save
  end
  
  def set_main_collection_policies(policies = {})
    policies.each do |p, c|
      @main.policy_groups[p] = c
    end
    
    @main.save
  end
  
end
