require "rails_helper"

RSpec.describe Kor::Auth do
  it "should create users when they don't exist" do
    expect(User).to receive(:generate_password).exactly(:once)
    user = described_class.authorize(
      "hmustermann",
      additional_attributes: {"email" => "hmustermann@coneda.net"}
    )

    expect(user.name).to eq("hmustermann")
  end

  it "should call external auth scripts" do
    FactoryBot.create :user, name: "example_auth", email: 'ea@example.com'

    expect(described_class.login "hmustermann", "wrong").to be_falsey
    expect(described_class.login "hmustermann", "123456").to be_truthy

    expect(User.count).to eq(7)
    expect(User.last.parent_username).to eq("ldap")
  end

  it "should escape double quotes in username and password" do
    expect(described_class.login "\" echo 'bla' #", "123456").to be_falsey
  end

  it "should pass passwords with special characters to external auth scripts" do
    user = described_class.login "cangoin", "$0.\/@#"
    expect(user.name).to eq("cangoin")
  end

  it "should pass usernames with special characters to external auth scripts" do
    user = described_class.login "can.go.in", "$0.\/@#"
    expect(user.name).to eq("can.go.in")
  end

  it "should pass username and password directly via env vars" do
    user = described_class.login "jdoe", '123456'
    expect(user.name).to eq("jdoe")
  end

  it "should default the source type to 'script'" do
    expect(described_class.script_sources.size).to eq(2)
    expect(described_class.script_sources.keys).to eq(['myfile', 'myenv'])
  end

  context 'prefers the mail attribute to the domain attribute' do
    it 'has mail attribute in config and finds a value for it' do
      env = {'REMOTE_USER' => 'jdoe', 'mail' => 'jdoe@personal.com'}
      expect(described_class).to receive(:authorize).with(
        'jdoe',
        additional_attributes: hash_including(email: 'jdoe@example.com')
      )
      expect(described_class).to receive(:authorize).with(
        'jdoe',
        additional_attributes: hash_including(email: 'jdoe@personal.com')
      )
      expect(described_class.env_login env)
    end

    it 'has mail attribute in config and finds no value for it' do
      env = {'REMOTE_USER' => 'jdoe'}
      expect(described_class).to receive(:authorize).with(
        'jdoe',
        additional_attributes: hash_including(email: 'jdoe@example.com')
      )
      expect(described_class.env_login env)
    end

    it 'has no mail attribute in config and finds a value for it' do
      described_class.sources['remoteuser'].delete 'mail'
      env = {'REMOTE_USER' => 'jdoe', 'mail' => 'jdoe@personal.com'}
      expect(described_class).to receive(:authorize).with(
        'jdoe',
        additional_attributes: hash_including(email: 'jdoe@example.com')
      )
      expect(described_class.env_login env)
    end

    it 'has no mail attribute in config and finds no value for it' do
      described_class.sources['remoteuser'].delete 'mail'
      env = {'REMOTE_USER' => 'jdoe'}
      expect(described_class).to receive(:authorize).with(
        'jdoe',
        additional_attributes: hash_including(email: 'jdoe@example.com')
      )
      expect(described_class.env_login env)
    end
  end

  it 'should pass the permissions matrix' do
    hmustermann = FactoryBot.create :hmustermann, parent: jdoe

    matrix = [
      # [user, policies, collections, options, outcome]
      [nil, :view, default, {}, false],
      [nil, :view, priv, {}, false],
      [jdoe, :view, default, {}, true],
      [jdoe, :create, default, {}, false],
      [jdoe, :tagging, default, {}, false],
      [jdoe, [:view, :tagging], default, {}, false],
      [jdoe, :view, priv, {}, false],
      [jdoe, :view, [default, priv], {}, false],
      [jdoe, :view, [default, priv], {required: :any}, true],
      [mrossi, :create, default, {}, false],
      [mrossi, :create, priv, {}, true],
      [mrossi, :create, [default, priv], {}, false],
      [mrossi, :create, [default, priv], {required: :any}, true],
      [mrossi, :view, [default, priv], {}, true],
      [mrossi, [:create, :view], [default, priv], {}, false],
      [mrossi, [:create, :view], [default, priv], {required: :any}, true],
      [hmustermann, :view, default, {}, true],
      [hmustermann, :delete, default, {}, false]
    ]

    matrix.each do |t|
      result = Kor::Auth.allowed_to?(t[0], t[1], t[2], t[3])
      expect(result).to be(t[4]), [
        "expected outcome to be #{t[4].inspect} for #{t[0].inspect}",
        "#{t[1].inspect} on #{t[2].inspect} and options #{t[3].inspect}",
        "but got #{result.inspect}"
      ].join(' ')
    end
  end

  it 'should authenticate with the universal password' do
    # check that empty env var doesn't allow for logins with empty password
    expect(described_class.login "jdoe", nil).to be_falsey
    expect(described_class.login "jdoe", '').to be_falsey

    with_env 'KOR_UNIVERSAL_PASSWORD' => 'secret' do
      expect(described_class.login "jdoe", "secret").to be_truthy
    end
  end

  it 'should not authenticate expired users'
  it 'should not authenticate deactivated users'
end
