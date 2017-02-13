module Paranoia
  def paranoia_restore_attributes
    {
      paranoia_column => paranoia_sentinel_value
    }.merge(timestamp_attributes_with_current_time)
  end

  def paranoia_destroy_attributes
    {
      paranoia_column => current_time_from_proper_timezone
    }.merge(timestamp_attributes_with_current_time)
  end

  def timestamp_attributes_with_current_time
    timestamp_attributes_for_update_in_model.each_with_object({}) { |attr,hash| hash[attr] = current_time_from_proper_timezone }
  end
end