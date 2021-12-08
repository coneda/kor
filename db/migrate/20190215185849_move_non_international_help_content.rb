class MoveNonInternationalHelpContent < ActiveRecord::Migration
  def up
    keys = [
      'general', 'search', 'upload', 'login', 'profile', 'entries',
      'authority_groups', 'user_groups', 'clipboard'
    ]

    keys.each do |key|
      Kor.settings.update("help_#{key}.en" => Kor.settings["help_#{key}"])
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
