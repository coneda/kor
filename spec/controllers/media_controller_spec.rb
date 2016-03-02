require 'rails_helper'

RSpec.describe MediaController, :type => :controller do
  include DataHelper

  before :each do
    fake_authentication :persist => true

    test_kinds
  end

  def side_collection
    @side_collection ||= FactoryGirl.create :private
  end

  def side_entity(attributes = {})
    Delayed::Worker.delay_jobs = false

    @side_entity ||= begin
      FactoryGirl.create :picture_a, :collection => side_collection
    end
  end

  def set_side_collection_policies(policies = {})
    policies.each do |p, c|
      side_collection.grant(p, :to => c)
    end
  end

  it "should not allow viewing to unauthorized users" do
    get :view, :id => side_entity.medium_id
    expect(response).to redirect_to(denied_path)
  end

  it "should allow viewing to authorized users" do
    set_side_collection_policies :view => [@admins]

    get :view, :id => side_entity.medium_id
    expect(response).not_to redirect_to(denied_path)
  end

  def params_for_medium(medium, style = :normal, attachment = :image, style_extension = :png)
    ids = medium.ids.split '/'
    return {
      :style => style,
      :id_part_01 => ids[0],
      :id_part_02 => ids[1],
      :id_part_03 => ids[2],
      :attachment => attachment,
      :style_extension => style_extension
    }
  end

  it "should not show imgages to unauthorized users" do
    get :show, params_for_medium(side_entity.medium)
    expect(response).to redirect_to(denied_path)
  end

  it "should show images to authorized users" do
    set_side_collection_policies :view => [@admins]

    get :show, params_for_medium(side_entity.medium)
    expect(response).not_to redirect_to(denied_path)
  end

  it "should not allow image download to unauthorized users" do
    get :download, :id => side_entity.medium_id, :style => :normal
    expect(response).to redirect_to(denied_path)
  end

  it "should allow image download to authorized users" do
    set_side_collection_policies(
      :view => [@admins], 
      :download_originals => [@admins]
    )

    get :download, :id => side_entity.medium_id, :style => :normal
    expect(response).not_to redirect_to(denied_path)
  end

  it "should allow original download only to authorized users" do
    set_side_collection_policies(:view => [@admins])

    get :download, :id => side_entity.medium_id, :style => :original
    expect(response).to redirect_to(denied_path)
  end

  it "should not allow image transformations to unauthorized users" do
    get :transform, :id => side_entity.medium_id, :transformation => 'image', :operation => 'flip'
    expect(response).to redirect_to(denied_path)
  end

  it "should allow image transformations to authorized users" do
    set_side_collection_policies :edit => [@admins]

    get :transform, :id => side_entity.medium_id, :transformation => 'image', :operation => 'flip'
    expect(response).not_to redirect_to(denied_path)
  end

end
