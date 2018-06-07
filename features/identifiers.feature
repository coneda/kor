Feature: Identifiers

# TODO: this test fails only on travis-ci ... why?
# @javascript @nodelay
# Scenario: Create a resolvable entity and resolve it
#   Given I am logged in as "admin"
#   And the kind "Person/People"
#   And I go to the kinds page
#   And I follow "Three bars" within the row for "kind" "Person"
#   And I follow "Plus"
#   And I fill in "field[name]" with "gnd_id"
#   And I fill in "field[show_label]" with "GND-ID"
#   And I check "field[is_identifier]"
#   And I press "Create"
#   And I go to the new "Person-Entity" page
#   And I fill in "entity[name]" with "Leonardo da Vinci"
#   And I fill in "entity[dataset][gnd_id]" with "1234"
#   And I press "Create"
#   And I go to the path "/resolve/gnd_id/1234"
#   Then I should see "Leonardo da Vinci"
#   And I should be on the entity page for "Leonardo da Vinci"
#   And I go to the path "/resolve/1234"
#   And I should see "Leonardo da Vinci"
#   And I should be on the entity page for "Leonardo da Vinci"

# ERROR:

# expected: #<URI::HTTP http://127.0.0.1:44878/blaze#/entities/1>
#      got: #<URI::HTTP http://127.0.0.1:44878/blaze#/denied?return_to=http:%2F%2F127.0.0.1:44878%2Fblaze%23%2Fentities%2F1>
# (compared using ==)
# Diff:
# @@ -1,2 +1,2 @@
# -#<URI::HTTP http://127.0.0.1:44878/blaze#/entities/1>
# +#<URI::HTTP http://127.0.0.1:44878/blaze#/denied?return_to=http:%2F%2F127.0.0.1:44878%2Fblaze%23%2Fentities%2F1>
#  (RSpec::Expectations::ExpectationNotMetError)
# ./features/step_definitions/web_steps.rb:87:in `/^(?:|I )should be on (.+)$/'
# ./features/support/kor.rb:11:in `block in <top (required)>'
# features/identifiers.feature:20:in `And I should be on the entity page for "Leonardo da Vinci"'