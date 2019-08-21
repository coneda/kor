require 'rails_helper'

RSpec.describe Kor::Search, elastic: true do
  it 'should use correct engine' do
    search = described_class.new(admin, terms: 'mona')
    expect(search.engine).to eq('elastic')

    search = described_class.new(admin, isolated: true)
    expect(search.engine).to eq('active_record')

    search = described_class.new(admin, name: 'mona')
    expect(search.engine).to eq('active_record')

    search = described_class.new(admin, terms: 'mona', engine: 'elastic')
    expect(search.engine).to eq('elastic')

    # not possible with elastic
    search = described_class.new(admin, isolated: true, engine: 'elastic')
    expect(search.engine).to eq('active_record')

    search = described_class.new(admin, name: 'mona', engine: 'elastic')
    expect(search.engine).to eq('elastic')
  end
end

RSpec.shared_examples 'a kor search' do
  it 'should raise an exception for unknown keys' do
    expect {
      described_class.new(jdoe, some: 'thing')
    }.to raise_error(Kor::Exception), '[:some] is not a valid search key'
  end

  it 'should search with the permissions of a given user' do
    search = described_class.new(jdoe)
    expect(search.total).to eq(5)

    search = described_class.new(admin)
    expect(search.total).to eq(7)
  end

  it 'should paginate' do
    search = described_class.new(admin, per_page: 2)
    expect(search.records.size).to eq(2)
    expect(search.total).to eq(7)

    search = described_class.new(admin, per_page: 4, page: 2)
    expect(search.records.size).to eq(3)
    expect(search.total).to eq(7)
  end

  it 'should sort by various criteria' do
    search = described_class.new(admin, except_kind_id: media.id)
    expect(search.total).to eq(5)
    expect(search.records.first).to eq(leonardo)
    expect(search.records.last).to eq(last_supper)

    monalisa = mona_lisa
    monalisa.update name: 'Monalisa'
    Kor::Elastic.refresh if Kor::Elastic.enabled?

    search = described_class.new(
      admin,
      except_kind_id: media.id,
      sort: { column: 'updated_at', direction: 'desc' }
    )
    expect(search.total).to eq(5)
    expect(search.records.first).to eq(monalisa)
  end

  it 'should search with the distinct name' do
    leonardo.update distinct_name: 'uzh-khist-gd-04207-53'
    Kor::Elastic.refresh if Kor::Elastic.enabled?

    search = described_class.new(admin, name: 'uzh-khist-gd-04207-53')
    expect(search.total).to eq(1)
  end

  it 'should search by collection' do
    search = described_class.new(admin, collection_id: [priv.id])
    expect(search.total).to eq(2)

    search = described_class.new(jdoe, collection_id: [priv.id])
    expect(search.total).to eq(0)
  end

  it 'should search by entity type' do
    search = described_class.new(admin, kind_id: [works.id])
    expect(search.total).to eq(2)
  end

  it 'should exclude by entity type' do
    search = described_class.new(admin, except_kind_id: [locations.id])
    expect(search.total).to eq(6)
  end

  it 'should search by tags' do
    search = described_class.new(admin, tags: ['art'])
    expect(search.total).to eq(2)

    search = described_class.new(admin, tags: ['late'])
    expect(search.total).to eq(1)

    search = described_class.new(admin, tags: ['early'])
    expect(search.total).to eq(1)

    search = described_class.new(admin, tags: ['early', 'art'])
    expect(search.total).to eq(1)

    search = described_class.new(admin, tags: ['early', 'late'])
    expect(search.total).to eq(0)
  end

  it 'should search by dating' do
    search = described_class.new(admin, dating: '14. Jahrhundert')
    expect(search.total).to eq(0)

    search = described_class.new(admin, dating: '15. Jahrhundert')
    expect(search.total).to eq(1)

    search = described_class.new(admin, dating: '16. Jahrhundert')
    expect(search.total).to eq(2)

    search = described_class.new(admin, dating: '17. Jahrhundert')
    expect(search.total).to eq(0)
  end

  it 'should search by relation name (to find to-candidates)' do
    search = described_class.new(admin, relation_name: 'has created')
    expect(search.total).to eq(2)

    search = described_class.new(admin, relation_name: 'is related to')
    expect(search.total).to eq(3)

    search = described_class.new(admin, relation_name: ['is related to', 'is located in'])
    expect(search.total).to eq(4)
  end

  it 'should search by creation time' do
    search = described_class.new(admin, created_after: last_supper.created_at)
    expect(search.total).to eq(4)

    search = described_class.new(admin, created_before: last_supper.created_at)
    expect(search.total).to eq(2)

    search = described_class.new(admin, created_before: Time.now)
    expect(search.total).to eq(7)

    search = described_class.new(admin,
      created_before: picture_a.created_at,
      created_after: last_supper.created_at
    )
    expect(search.total).to eq(2)
  end

  it 'should search by update time' do
    search = described_class.new(admin, updated_after: last_supper.updated_at)
    expect(search.total).to eq(4)

    search = described_class.new(admin, updated_before: last_supper.updated_at)
    expect(search.total).to eq(2)

    search = described_class.new(admin, updated_before: Time.now)
    expect(search.total).to eq(7)

    search = described_class.new(admin,
      updated_after: last_supper.updated_at,
      updated_before: picture_a.updated_at
    )
    expect(search.total).to eq(2)
  end

  it 'should search by id and uuid' do
    search = described_class.new(admin, id: mona_lisa.id)
    expect(search.total).to eq(1)
    expect(search.records.first).to eq(mona_lisa)

    search = described_class.new(admin, uuid: mona_lisa.uuid)
    expect(search.total).to eq(1)
    expect(search.records.first).to eq(mona_lisa)

    search = described_class.new(admin, id: 'invalid-id')
    expect(search.total).to eq(0)

    search = described_class.new(admin, uuid: 'invalid-id')
    expect(search.total).to eq(0)
  end

  it 'should search by creator & updater' do
    search = described_class.new(admin, created_by: admin.id)
    expect(search.total).to eq(5)

    search = described_class.new(admin, updated_by: mrossi.id)
    expect(search.total).to eq(2)
  end
end

RSpec.describe Kor::Search do
  context 'without elasticsearch' do
    before :each do
      allow(Kor::Elastic).to receive(:available?).and_return(false)
    end

    it_behaves_like 'a kor search'

    it 'should search by name' do
      search = described_class.new(admin, name: 'ar')
      expect(search.total).to eq(2)

      search = described_class.new(admin, name: 'léönärdö')
      expect(search.total).to eq(1)
    end

    it 'should search by authority group' do
      search = described_class.new(admin, authority_group_id: lecture.id)
      expect(search.total).to eq(1)

      search = described_class.new(jdoe, authority_group_id: lecture.id)
      expect(search.total).to eq(1)

      search = described_class.new(admin, authority_group_id: seminar.id)
      expect(search.total).to eq(0)
    end

    it 'should search by user group' do
      search = described_class.new(admin, user_group_id: nice.id)
      expect(search.total).to eq(7) # incorrect owner, so user_group_id is ignored

      search = described_class.new(jdoe, user_group_id: nice.id)
      expect(search.total).to eq(1)
    end

    it 'should search by creator & updater' do
      search = described_class.new(admin, created_by: admin.id)
      expect(search.total).to eq(5)

      search = described_class.new(admin, updated_by: mrossi.id)
      expect(search.total).to eq(2)
    end

    it 'should search by isolated' do
      search = described_class.new(admin, isolated: true)
      expect(search.total).to eq(0)

      louvre.destroy
      search = described_class.new(admin, isolated: true)
      expect(search.total).to eq(1)
      expect(search.records.first).to eq(paris)
    end

    it 'should search by invalid' do
      search = described_class.new(admin, invalid: true)
      expect(search.total).to eq(0)

      duplicate = works.entities.new(
        collection: default,
        name: 'Leonardo'
      )
      duplicate.save validate: false
      duplicate.mark_invalid

      search = described_class.new(admin, invalid: true)
      expect(search.total).to eq(1)
      expect(search.records.first).to eq(duplicate)
    end

    it 'should raise an exception for elasticsearch-only criteria' do
      expect {
        described_class.new(admin, terms: 'lis*')
      }.to raise_error(Kor::Exception, 'terms is only supported with elasticsearch')

      expect {
        described_class.new(admin, dataset: { 'gnd_id' => '12345' })
      }.to raise_error(Kor::Exception, 'dataset is only supported with elasticsearch')

      expect {
        described_class.new(admin, property: { 'age' => '41' })
      }.to raise_error(Kor::Exception, 'property is only supported with elasticsearch')

      expect {
        described_class.new(admin, related: 'mona')
      }.to raise_error(Kor::Exception, 'related is only supported with elasticsearch')
    end
  end

  context 'with elasticsearch', elastic: true do
    before :each do
      allow_any_instance_of(Kor::Search).to receive(:preferred_engine).and_return('elastic')
    end

    # do all of the above
    it_behaves_like 'a kor search'

    it 'should search by name' do
      search = described_class.new(admin, name: 'ar')
      expect(search.total).to eq(0)

      search = described_class.new(admin, name: '*ar*')
      expect(search.total).to eq(2)

      search = described_class.new(admin, name: 'léönärdö')
      expect(search.total).to eq(1)

      search = described_class.new(admin, name: 'léö*')
      expect(search.total).to eq(1)

      search = described_class.new(admin, name: 'léö')
      expect(search.total).to eq(0)
    end

    it 'should search by terms' do
      search = described_class.new(admin, terms: 'mona')
      expect(search.total).to eq(5)

      search = described_class.new(admin, terms: 'mona -leonardo')
      expect(search.total).to eq(2)
      expect(search.records).to include(picture_a, louvre)

      search = described_class.new(admin, terms: 'pop')
      expect(search.total).to eq(0)

      search = described_class.new(admin, terms: 'pop*')
      expect(search.total).to eq(1)

      search = described_class.new(admin, terms: 'ar*')
      expect(search.total).to eq(2)

      search = described_class.new(admin, terms: '*ar*')
      expect(search.total).to eq(5)

      people.entities.create(
        collection: default,
        name: 'Désirée Müller'
      )
      Kor::Elastic.refresh

      search = described_class.new(admin, terms: 'Mül*')
      expect(search.total).to eq(1)

      search = described_class.new(admin, terms: 'mül*')
      expect(search.total).to eq(1)

      search = described_class.new(admin, terms: 'mul*')
      expect(search.total).to eq(1)

      search = described_class.new(admin, terms: '*ull*')
      expect(search.total).to eq(1)

      search = described_class.new(admin, terms: '*üll*')
      expect(search.total).to eq(1)

      search = described_class.new(admin, terms: '*Üll*')
      expect(search.total).to eq(1)

      search = described_class.new(admin, terms: '*ller*')
      expect(search.total).to eq(1)

      search = described_class.new(admin, terms: '*ller')
      expect(search.total).to eq(1)
    end

    it 'should search by name' do
      # we have to force elastic here since name: is s compat query
      search = described_class.new(admin, name: 'ar')
      expect(search.total).to eq(0)

      search = described_class.new(admin, name: '*ar*')
      expect(search.total).to eq(2)

      search = described_class.new(admin, name: 'léönärdö')
      expect(search.total).to eq(1)

      search = described_class.new(admin, name: 'léö*')
      expect(search.total).to eq(1)
    end

    it 'should search by synonym' do
      search = described_class.new(admin, terms: 'giocondo')
      expect(search.total).to eq(5) # synonyms are indexed with related entities
    end

    it 'should search by property' do
      search = described_class.new(admin, property: 'Renaissance')
      expect(search.total).to eq(1)

      search = described_class.new(admin, property: '*naissance')
      expect(search.total).to eq(1)
    end

    it 'should search by dataset' do
      search = described_class.new(admin, dataset: { 'gnd_id' => '123456789' })
      expect(search.total).to eq(1)

      search = described_class.new(admin, dataset: { 'gnd_id' => 'xxxx' })
      expect(search.total).to eq(0)
    end

    it 'should search by related entities' do
      search = described_class.new(admin, related: 'mona')
      expect(search.total).to eq(4)

      search = described_class.new(jdoe, related: 'mona')
      expect(search.total).to eq(3) # he can't see the last supper

      search = described_class.new(admin, related: 'supper')
      expect(search.total).to eq(3)

      search = described_class.new(jdoe, related: 'supper')
      # he can't see, so no related entities can be found by that term
      expect(search.total).to eq(0)
    end

    it 'should search by degree ranges' do
      search = described_class.new(admin, degree: 2)
      expect(search.total).to eq(2)

      search = described_class.new(admin, degree: 5)
      expect(search.total).to eq(0)

      search = described_class.new(admin, degree: 0)
      expect(search.total).to eq(0)

      search = described_class.new(admin, min_degree: 2)
      expect(search.total).to eq(4)

      search = described_class.new(admin, min_degree: 1)
      expect(search.total).to eq(7)

      search = described_class.new(admin, min_degree: 0)
      expect(search.total).to eq(7)

      search = described_class.new(admin, min_degree: 3)
      expect(search.total).to eq(2)

      search = described_class.new(admin, min_degree: 5)
      expect(search.total).to eq(0)

      search = described_class.new(admin, max_degree: 0)
      expect(search.total).to eq(0)

      search = described_class.new(admin, max_degree: 3)
      expect(search.total).to eq(6)
    end
  end
end
