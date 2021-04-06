# Collation can't be set reliably with migrations because they are not exported
# to schema.rb so new setups will end up using whatever is configured in the
# db connection string, this makes sure the tag name column is always using a
# binary collation

if Rails.env.test?
  old = ActiveRecord::Migration.verbose
  ActiveRecord::Migration.verbose = false
  ActsAsTaggableOn.force_binary_collation = true
  ActiveRecord::Migration.verbose = old
else
  ActsAsTaggableOn.force_binary_collation = true
end
