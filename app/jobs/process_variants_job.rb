class ProcessVariantsJob < ActiveJob::Base
  queue_as :default

  def perform(medium_id)
    Medium.find(medium_id).rebuild_variants
  end
end
