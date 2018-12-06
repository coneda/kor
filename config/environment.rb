# Set the app root so that dotenv can make it available in .env files
ENV['KOR_ROOT'] = File.expand_path(__dir__ + '/..')

# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!
