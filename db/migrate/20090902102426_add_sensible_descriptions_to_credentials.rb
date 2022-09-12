class AddSensibleDescriptionsToCredentials < ActiveRecord::Migration
  def self.up
    credential = Credential.find_by_name('users')
    credential.update(:description => 'Nutzungsrechte')

    credential = Credential.find_by_name('editors')
    credential.update(:description => 'Einfache Änderungsrechte')

    credential = Credential.find_by_name('maintainers')
    credential.update(:description => 'Erweiterte Änderungsrechte')

    credential = Credential.find_by_name('admins')
    credential.update(:description => 'Administratorrechte')
  end

  def self.down
  end
end
