require 'rails_helper'

RSpec.describe PublishmentsController, type: 'controller' do
  render_views

  before :each do
    @publishment = Publishment.create!(
      name: 'for meeting',
      user: jdoe,
      user_group: nice
    )
  end

  it 'should not GET index' do
    get 'index'
    expect(response).to be_unauthorized
  end

  it 'should not GET show (wrong hash)' do
    get 'show', params: { user_id: jdoe.id, uuid: @publishment.id }
    expect(response).to be_not_found
  end

  it 'should GET show (correct hash)' do
    get 'show', params: { user_id: jdoe.id, uuid: @publishment.uuid }
    expect(response).to be_success
    expect(json['name']).to eq('for meeting')
  end

  it 'should not GET show (correct hash, expired)' do
    @publishment.update valid_until: 3.days.ago

    get 'show', params: { user_id: jdoe.id, uuid: @publishment.uuid }
    expect(response).to be_not_found
  end

  it 'should not PATCH extend' do
    expect(@publishment.valid_until).to be_within(1.second).of(2.weeks.from_now)

    patch 'extend_publishment', params: {
      id: @publishment.id,
      publishment: {
        valid_until: 4.weeks.from_now
      }
    }
    expect(response).to be_unauthorized
  end

  it 'should not POST create' do
    post 'create', params: {
      publishment: {
        name: 'for tomorrow',
        user_group_id: nice.id
      }
    }
    expect(response).to be_unauthorized
  end

  it 'should not DELETE destroy' do
    delete 'destroy', params: { id: @publishment.id }
    expect(response).to be_unauthorized
  end

  context 'as jdoe' do
    before :each do
      current_user User.find_by!(name: 'jdoe')
    end

    it 'should GET index' do
      get 'index'
      expect(response).to be_success
      expect(json['total']).to eq(1)
      expect(json['records'][0]['name']).to eq('for meeting')
    end

    it 'should PATCH extend' do
      expect(@publishment.valid_until).to be_within(1.second).of(2.weeks.from_now)

      patch 'extend_publishment', params: { 
        id: @publishment.id,
        publishment: {
          valid_until: 4.weeks.from_now
        }
      }
      expect(response).to be_success
      # not easy to verify the timestamp for now
    end

    it 'should POST create' do
      post 'create', params: {
        publishment: {
          name: 'for tomorrow',
          user_group_id: nice.id
        }
      }
      expect_created_response
      expect(Publishment.find(json['id']).name).to eq('for tomorrow')
    end

    it 'should DELETE destroy' do
      delete 'destroy', params: { id: @publishment.id }
      expect_deleted_response
      expect(Publishment.find_by(id: json['id'])).to be_nil
    end
  end
end
