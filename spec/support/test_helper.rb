module TestHelper
  def with_env(overrides = {})
    old = {}
    overrides.each do |k, v|
      old[k] = ENV[k]
      ENV[k] = v
    end
    yield
    old.each do |k, v|
      ENV[k] = old[k]
    end
  end

  def self.before_each(framework, scope, test)
    system "rm -rf #{ENV['DATA_DIR']}/media/"
    system "cp -a #{Rails.root}/tmp/test.media.clone #{ENV['DATA_DIR']}/media"

    FactoryGirl.reload
    Kor::Auth.sources(refresh: true)

    use_elastic = (
      framework == :rspec && test.metadata[:elastic] ||
      framework == :cucumber && test.tags.any?{ |st| st.name == '@elastic' }
    )

    if use_elastic
      Kor::Elastic.enabled = true
      Kor::Elastic.reset_index
      Kor::Elastic.index_all full: true
    else
      Kor::Elastic.enabled = false
    end
  end
end