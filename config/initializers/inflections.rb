# module ActionController::RequestForgeryProtection
#   def valid_authenticity_token?(session, encoded_masked_token)
#     if encoded_masked_token.nil? || encoded_masked_token.empty? || !encoded_masked_token.is_a?(String)
#       return false
#     end

#     begin
#       masked_token = Base64.strict_decode64(encoded_masked_token)
#     rescue ArgumentError # encoded_masked_token is invalid Base64
#       return false
#     end
    

#     # See if it's actually a masked token or not. In order to
#     # deploy this code, we should be able to handle any unmasked
#     # tokens that we've issued without error.

#     if masked_token.length == AUTHENTICITY_TOKEN_LENGTH
#       # This is actually an unmasked token. This is expected if
#       # you have just upgraded to masked tokens, but should stop
#       # happening shortly after installing this gem
#       compare_with_real_token masked_token, session

#     elsif masked_token.length == AUTHENTICITY_TOKEN_LENGTH * 2
#       # Split the token into the one-time pad and the encrypted
#       # value and decrypt it
#       one_time_pad = masked_token[0...AUTHENTICITY_TOKEN_LENGTH]
#       encrypted_csrf_token = masked_token[AUTHENTICITY_TOKEN_LENGTH..-1]
#       csrf_token = xor_byte_strings(one_time_pad, encrypted_csrf_token)
#     binding.pry

#       compare_with_real_token csrf_token, session

#     else
#       false # Token is malformed
#     end
#   end

# end

# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym 'RESTful'
# end
