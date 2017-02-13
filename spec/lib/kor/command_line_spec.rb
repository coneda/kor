require 'rails_helper'

describe Kor::CommandLine do

  def run(args)
    cmd = described_class.new(args.split ' ')
    cmd.set :verbose, false
    cmd.parse_options
    cmd.run
  end

  it 'should start reprocessing all images' do
    expect(Kor::Tasks).to receive(:reprocess_all)
    run 'reprocess-all'
  end

  it 'should start indexing everything' do
    expect(Kor::Tasks).to receive(:index_all)
    run 'index-all'
  end

  it 'should start zipping a group' do
    expect(Kor::Tasks).to receive(:group_to_zip).with(hash_including(
      group_id: 123,
      class_name: 'UserGroup'
    ))
    run 'group-to-zip --group-id=123 --class-name=UserGroup'
  end

  it 'should start notifying expiring user accounts' do
    expect(Kor::Tasks).to receive(:notify_expiring_users)
    run 'notify-expiring-users'
  end

  it 'should start rechecking invalid entities' do
    expect(Kor::Tasks).to receive(:recheck_invalid_entities)
    run 'recheck-invalid-entities'
  end

  it 'should start deleting expired downloads' do
    expect(Kor::Tasks).to receive(:delete_expired_downloads)
    run 'delete-expired-downloads'
  end

  it 'should start collecting editor stats' do
    expect(Kor::Tasks).to receive(:editor_stats)
    run 'editor-stats'
  end

  it 'should start collecting exif stats' do
    expect(Kor::Tasks).to receive(:exif_stats).with(hash_including(
      from: '2016-12-01',
      to: '2016-12-31'
    ))
    run 'exif-stats -f 2016-12-01 -t 2016-12-31'
  end

  it 'should start resetting the admin account' do
    expect(Kor::Tasks).to receive(:reset_admin_account)
    run 'reset-admin-account'
  end

  it 'should start resetting the guest account' do
    expect(Kor::Tasks).to receive(:reset_guest_account)
    run 'reset-guest-account'
  end

  it 'should start importing everyghing to neo4j' do
    expect(Kor::Tasks).to receive(:to_neo)
    run 'to-neo'
  end

  it 'should start finding the shortest path between two random entities' do
    expect(Kor::Tasks).to receive(:connect_random)
    run 'connect-random'
  end

  it 'should start listing permissions' do
    expect(Kor::Tasks).to receive(:list_permissions).with(hash_including(
      entity_id: "123",
      user_id: "456"
    ))
    run 'list-permissions -e 123 -u 456'
  end

  it 'should start generating secrets' do
    expect(Kor::Tasks).to receive(:secrets)
    run 'secrets'
  end

  it 'should start a consistency check' do
    expect(Kor::Tasks).to receive(:consistency_check)
    run 'consistency-check'
  end

  it 'should start an excel export' do
    export = double('export')
    expect(Kor::Export::Excel).to receive(:new).and_return(export).with(
      '/some/dir',
      hash_including(
        format: 'excel',
        collection_id: [3, 6, 9],
        kind_id: [1, 6],
        username: 'jdoe'
      )
    )
    expect(export).to receive(:run)
    run 'export -f excel -u jdoe --collection-id=3,6,9 --kind-id=1,6 /some/dir'
  end

  it 'should start an excel import' do
    import = double('import')
    expect(Kor::Import::Excel).to receive(:new).and_return(import).with(
      '/some/dir',
      hash_including(
        format: 'excel',
        username: 'jdoe',
        ignore_stale: true,
        obey_permissions: true,
        simulate: true,
        ignore_validations: true
      )
    )
    expect(import).to receive(:run)
    run 'import -f excel -u jdoe -i -p -s -o /some/dir'
  end

end