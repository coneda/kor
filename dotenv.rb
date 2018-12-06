require 'dotenv'

current_env = (defined?(Rails) ? Rails.env : 'development')

# we set the root and pass it on to the .env files so that we can use KOR_ROOT
# there
dotenv_root = File.expand_path(__dir__)
ENV['KOR_ROOT'] = dotenv_root

Dotenv.load(
  "#{dotenv_root}/.env.#{current_env}",
  "#{dotenv_root}/.env"
)

required = [
  'SECRET_KEY_BASE',
  'MEDIA_DIR',
  'DATABASE_URL',
  'MAIL_DELIVERY_METHOD'
]

required.each do |k|
  unless ENV.has_key?(k)
    raise StandardError, "configuration #{k} needs to be set"
  end
end
