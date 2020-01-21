class MoveNonInternationalHelpContent < ActiveRecord::Migration
  def up
    config = Kor::Config.new(Kor::Config.app_config_file)
    help = Kor.config['help']

    help.keys.each do |section|
      help[section].keys.each do |page|
        old = help[section][page]
        help[section][page] = {'en' => old}
      end
    end

    config.update('help' => help)
    config.store(Kor::Config.app_config_file)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
