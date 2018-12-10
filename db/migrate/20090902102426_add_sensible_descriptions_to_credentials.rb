class AddSensibleDescriptionsToCredentials < ActiveRecord::Migration
  def self.up
    credential = Credential.find_by_name('users')
    credential.update_attributes(:description => 'Nutzungsrechte')

    credential = Credential.find_by_name('editors')
    credential.update_attributes(:description => 'Einfache Änderungsrechte')

    credential = Credential.find_by_name('maintainers')
    credential.update_attributes(:description => 'Erweiterte Änderungsrechte')

    credential = Credential.find_by_name('admins')
    credential.update_attributes(:description => 'Administratorrechte')
  end

  def self.down
  end
end
