class Grant < ApplicationRecord
  self.table_name = 'collections_credentials'

  belongs_to :collection, optional: true
  belongs_to :credential, optional: true

  scope :with_policy, lambda{ |name|
    name.blank? ? all : where(:policy => name)
  }
  scope :with_credential, lambda{ |credential|
    credential.present? ? where(credential: credential) : all
  }

  def personal?
    !!credential.owner
  end
end
