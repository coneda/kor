require 'rails_helper'

RSpec.describe ToolsController, :type => :controller do
  render_views
  
  include DataHelper

  before :each do
    test_data
  
    fake_authentication :user => User.admin
  end
  
  it "should reset the clipboard" do
    FactoryGirl.create :mona_lisa, :name => 'Monalisa', :dataset => {
      :gnd => '123456',
      :google_maps => 'Deutsche Straße 12, Frankfurt'
    }

    session[:clipboard] = [
      Entity.find_by_name("Mona Lisa").id,
      Entity.find_by_name("Monalisa").id
    ]
    
    get :mark, :mark => 'reset'

    expect(response).to be_redirect
    expect(session[:clipboard]).to be_empty
  end
  
  it "should show the clipboard when entities are in it" do
    FactoryGirl.create :mona_lisa, :name => 'Monalisa', :dataset => {
      :gnd => '123456',
      :google_maps => 'Deutsche Straße 12, Frankfurt'
    }

    session[:clipboard] = [
      Entity.find_by_name("Mona Lisa").id,
      Entity.find_by_name("Monalisa").id
    ]
    
    get :clipboard
    expect(response).to be_success
    expect(response.body).to match /Mona Lisa/
    expect(response.body).to match /Monalisa/
  end
  
  it "should render a mass relate form only with allowed relations" do
    @mona_lisa = Entity.find_by_name('Mona Lisa')
    @leonardo = FactoryGirl.create :leonardo
    
    session[:clipboard] = [ @leonardo.id ]
    session[:current_entity] = @mona_lisa.id
  
    post :new_clipboard_action, :clipboard_action => 'mass_relate', :selected_entity_ids => [@leonardo.id]
    expect(response).to be_success
    
    expect(response.body).to have_selector('select') do
      have_selector 'option', 'hat erschaffen'
      have_selector 'option', 'ist Ort von'
    end
  end

  it "should merge two entities with datings" do
    Entity.destroy_all

    original = FactoryGirl.create :mona_lisa, datings: [
      EntityDating.new(label: 'Dating', dating_string: '1503')
    ]
    duplicate = FactoryGirl.create :mona_lisa, name: 'Mona Liza', datings: [
      EntityDating.new(label: 'Dating', dating_string: '1603')
    ]
    entity_ids = [original.id, duplicate.id]

    post :clipboard_action, 
      :clipboard_action => 'merge', 
      :entity_ids => entity_ids,
      :entity => { 
        :name => 'Mona Lisa', 
        :kind_id => Kind.find_by_name('Werk').id,
      }

    expect(Entity.count).to eq(1)
    expect(Entity.first.datings.count).to eq(2)    
  end
  
  it "should merge two entities with datasets" do
    @monalisa = FactoryGirl.create :mona_lisa, :name => 'Monalisa', :dataset => {
      :gnd => '123456',
      :google_maps => 'Deutsche Straße 12, Frankfurt'
    }

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

    expect(Entity.first.name).to eql("Mona Lisa")
    expect(Entity.first.dataset['material']).to eql('oil on paper')
    expect(Entity.first.dataset).not_to be_nil
  end

  # TODO: does this test the right thing?  
  it "should merge two entities while not messing up the groups" do
    FactoryGirl.create :mona_lisa, :name => 'Monalisa', :dataset => {
      :gnd => '123456',
      :google_maps => 'Deutsche Straße 12, Frankfurt'
    }    

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

    expect(Entity.first.name).to eql("Mona Lisa")
  end
  
  it "should merge two images while not messing up the groups" do
    picture_a = FactoryGirl.create :picture_a
    picture_b = FactoryGirl.create :picture_b
    
    entity_ids = [picture_a.id, picture_b.id]
    
    group_1 = AuthorityGroup.create(:name => 'group 1')
    group_1.add_entities(picture_a)
    group_1.add_entities(picture_b)
       
    group_2 = AuthorityGroup.create(:name => 'group 2')
    group_2.add_entities(picture_b)
    
    post :clipboard_action, 
      :clipboard_action => 'merge', 
      :entity_ids => entity_ids,
      :entity => {:id => picture_a.id}
    
    expect(Entity.all).not_to include(picture_b)
    
    expect(picture_a.authority_groups).to include(group_1)
    expect(picture_a.authority_groups).to include(group_2)
      
    expect(response).to redirect_to(web_path(:anchor => "/entities/#{picture_a.id}"))
  end
  
  it "should merge entities while not loosing comments" do
    FactoryGirl.create :mona_lisa, :name => 'Monalisa', :dataset => {
      :gnd => '123456',
      :google_maps => 'Deutsche Straße 12, Frankfurt'
    }

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
      
    expect(Entity.find_by_name('Mona Lisa').comment).to eql("comment 1")
  end

end
