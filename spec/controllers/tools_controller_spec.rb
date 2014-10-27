require 'spec_helper'

describe ToolsController do
  render_views
  
  include DataHelper
  include AuthHelper

  before :each do
    test_data
  
    fake_authentication :user => User.admin
  end
  
  it "should reset the clipboard" do
    session[:clipboard] = [
      Entity.find_by_name("Mona Lisa").id,
      Entity.find_by_name("Monalisa").id
    ]
    
    get :mark, :mark => 'reset'

    response.should be_redirect
    session[:clipboard].should be_empty
  end
  
  it "should show the clipboard when entities are in it" do
    session[:clipboard] = [
      Entity.find_by_name("Mona Lisa").id,
      Entity.find_by_name("Monalisa").id
    ]
    
    get :clipboard
    response.should be_success
    response.body.should match /Mona Lisa/
    response.body.should match /Monalisa/
  end
  
  it "should render a mass relate form only with allowed relations" do
    @mona_lisa = Entity.find_by_name('Mona Lisa')
    @leonardo = @person_kind.entities.make(:name => 'Leonardo da Vinci')
    
    session[:clipboard] = [ @leonardo.id ]
    session[:current_entity] = @mona_lisa.id
  
    post :new_clipboard_action, :clipboard_action => 'mass_relate', :selected_entity_ids => [@leonardo.id]
    response.should be_success
    
    response.should have_selector('select') do
      have_selector 'option', 'hat erschaffen'
      have_selector 'option', 'ist Ort von'
    end
  end
  
  def merge_entities
    admins = [ Credential.find_by_name('admins').id ]
    collection = Collection.make(:name => 'Test Collection', :policy_groups => {
      'delete' => admins, 'create' => admins
    })
  
    Entity.make(:name => 'Mona Lisa',
      :collection => collection,
      :kind => Kind.find_by_name('Werk'),
      :dataset => Artwork.new
    )
    Entity.make(:name => 'Monalisa', 
      :collection => collection,
      :kind => Kind.find_by_name('Werk'),
      :dataset => Artwork.new
    )
  end

  it "should merge two entities with datasets" do
    entity_ids = [
      @monalisa.id,
      @mona_lisa.id
    ]

    post :clipboard_action, 
      :clipboard_action => 'merge', 
      :entity_ids => entity_ids,
      :entity => { 
        :name => 'Mona Lisa', 
        :kind_id => Kind.find_by_name('Werk').id,
        :dataset => {:material => 'oil on paper'}
      }
    expect(response).to redirect_to(web_path(:anchor => "/entities/#{Entity.first.id}"))

    Entity.first.name.should eql("Mona Lisa")
    Entity.first.dataset['material'].should eql('oil on paper')
    Entity.first.datings.first.dating_string.should eql("1533")
    Entity.first.dataset.should_not be_nil
  end
  
  it "should merge two entities while not messing up the groups" do
    entity_ids = [
      Entity.find_by_name("Mona Lisa").id,
      Entity.find_by_name("Monalisa").id
    ]

    post :clipboard_action, 
      :clipboard_action => 'merge', 
      :entity_ids => entity_ids,
      :entity => { 
        :name => 'Mona Lisa', 
        :kind_id => Kind.find_by_name('Werk').id
      }
      expect(response).to redirect_to(web_path(:anchor => "/entities/#{Entity.first.id}"))

    Entity.first.name.should eql("Mona Lisa")
    Entity.first.datings.first.dating_string.should eql("1533")
  end
  
  def create_image(file_name)
    Kind.image_kind.entities.make(:dataset_attributes => {:data => File.read(file_name)})
  end
  
  it "should merge two images while not messing up the groups" do
    image_a = Entity.make(:medium, :medium => Medium.make_unsaved)
    image_b = Entity.make(:medium, :medium => Medium.make_unsaved(:b))
    
    entity_ids = [image_a.id, image_b.id]
    
    group_1 = AuthorityGroup.create(:name => 'group 1')
    group_1.add_entities(image_a)
    group_1.add_entities(image_b)
       
    group_2 = AuthorityGroup.create(:name => 'group 2')
    group_2.add_entities(image_b)
    
    post :clipboard_action, 
      :clipboard_action => 'merge', 
      :entity_ids => entity_ids,
      :entity => {:id => image_a.id}
      
    Entity.count.should eql(3) # the image plus the two "mona lisas"
    Entity.find_by_id(image_b.id).should be_nil
    
    image_a.authority_groups.should include(group_1)
    image_a.authority_groups.should include(group_2)
      
    expect(response).to redirect_to(web_path(:anchor => "/entities/#{image_a.id}"))
  end
  
  it "should merge entities while not loosing comments" do
    Entity.find_by_name('Mona Lisa').update_attributes(:comment => 'comment 1')
    Entity.find_by_name('Monalisa').update_attributes(:comment => 'comment 2')
  
    post :clipboard_action, 
      :clipboard_action => 'merge', 
      :entity_ids => Entity.all.map{|e| e.id},
      :entity => { 
        :name => 'Mona Lisa', 
        :comment => 'comment 1',
        :kind_id => Kind.find_by_name('Werk').id
      }
      
    Entity.find_by_name('Mona Lisa').comment.should eql("comment 1")
  end

end
