module TestHelper
  def self.before_suite
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.strategy = :transaction

    system "cat /dev/null >| #{Rails.root}/log/test.log"

    XmlHelper.compile_validator

    # DatabaseCleaner.strategy = :transaction

    Kor::Settings.purge_files!
    Kor::Settings.instance.ensure_fresh
    Kor.settings.update(
      'primary_relations' => ['shows'],
      'secondary_relations' => ['has been created by']
    )
    
    Delayed::Worker.delay_jobs = false
    Rails.application.load_seed
    DataHelper.default_setup relationships: true, pictures: true

    system "rm -rf #{Rails.root}/tmp/test.media.clone"
    system "mv #{Medium.media_data_dir} #{Rails.root}/tmp/test.media.clone"
  end

  def self.around_each(example)
    begin
      DatabaseCleaner.start
      example.run
      DatabaseCleaner.clean
    rescue ActiveRecord::RecordInvalid => e
      binding.pry
      p e.record.errors.full_messages
    end
  end

  def self.before_each(scope, example)
    system "rm -rf #{Medium.media_data_dir}/"
    system "cp -a #{Rails.root}/tmp/test.media.clone #{Medium.media_data_dir}"
      
    FactoryGirl.reload
    Kor::Auth.sources(true)

    if example.metadata[:elastic]
      Kor::Elastic.enable
      Kor::Elastic.reset_index
      Kor::Elastic.index_all full: true
    else
      Kor::Elastic.disable
    end

    if example.metadata[:type].to_s == 'controller'
      scope.request.headers["accept"] = 'application/json'
    end

    ActionMailer::Base.deliveries.clear
    system "rm -rf #{Rails.root}/tmp/export_spec"
    
    Kor::Settings.purge_files!
    Kor::Settings.instance.ensure_fresh
    Kor.settings.update(
      'primary_relations' => ['shows'],
      'secondary_relations' => ['has been created by']
    )
  end
end