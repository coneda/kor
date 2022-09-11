class MoveNonInternationalHelpContent < ActiveRecord::Migration[4.2]
  def up
    keys = [
      'general', 'search', 'upload', 'login', 'profile', 'entries',
      'authority_groups', 'user_groups', 'clipboard'
    ]

    keys.each do |key|
      value = Kor.settings["help_#{key}"]

      if value.present?
        Kor.settings.update("help_#{key}.en" => value)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
