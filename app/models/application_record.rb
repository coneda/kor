# TODO: make all models inherit from this
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.pageit(page, per_page)
    return all if per_page == 'max'

    offset((page - 1) * per_page).limit(per_page)
  end
end
