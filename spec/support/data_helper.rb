# encoding: utf-8

module DataHelper

  def fake_authentication(options = {})
    options.reverse_merge!(:persist => false)
    
    if options[:persist]
      test_data_for_auth
      options[:user] ||= User.admin
    end
    
    session[:user_id] = options[:user].id
    session[:expires_at] = Kor.session_expiry_time
  end

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
    end
  end

  def test_data_for_auth
    @admins = FactoryGirl.create :admins
    @main = FactoryGirl.create :default
    @main.policies.each do |policy|
      Grant.create(:collection => @main, :credential => @admins, :policy => policy)
    end
    @admin = FactoryGirl.create :admin, :groups => Credential.all
  end
  
  def test_relations
    FactoryGirl.create :has_created,
      :from_kind_ids => [@person_kind.id], :to_kind_ids => [@artwork_kind.id]
    FactoryGirl.create :is_equivalent_to,
      :from_kind_ids => [@artwork_kind.id], :to_kind_ids => [@artwork_kind.id]
    FactoryGirl.create :is_located_at,
      :from_kind_ids => [@artwork_kind.id], :to_kind_ids => [@location_kind.id]
    FactoryGirl.create :shows,
      :from_kind_ids => [@medium_kind.id], :to_kind_ids => [@artwork_kind.id]
  end
  
  def test_kinds
    @medium_kind = Kind.create!(:name => Medium.model_name.human, :plural_name => Medium.model_name.human(:count => :other),
      :settings => {
        :naming => false
      }
    )
    @person_kind = FactoryGirl.create :people
    @artwork_kind = FactoryGirl.create :works
    @institution_kind = FactoryGirl.create :institutions
    @location_kind = FactoryGirl.create :locations
    @literature_kind = FactoryGirl.create :literatures
  end

  def test_entities  
    @mona_lisa = FactoryGirl.create :mona_lisa, :datings => [FactoryGirl.build(:d1533)]
  end
  
  def test_authority_groups
    FactoryGirl.create :authority_group, :name => 'Sander'
  end
  
end
