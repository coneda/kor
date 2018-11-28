module HtmlSelectorsHelpers
  # Maps a name to a selector. Used primarily by the
  #
  #   When /^(.+) within (.+)$/ do |step, scope|
  #
  # step definitions in web_steps.rb
  #
  def selector_for(locator)
    case locator

    when /the row for authority group category "([^\"]+)"/
      [:css, '[data-is=kor-admin-group-categories] tr', {text: $1}]

    when /the row for credential "([^\"]+)"/
      [:css, '[data-is=kor-credentials] tr', {text: $1}]

    when /the row for collection "([^\"]+)"/
      [:css, '[data-is=kor-collections] tr', {text: $1}]

    when /the row for authority group "([^\"]+)"/
      [:css, 'kor-admin-groups tr', {text: $1}]

    when /the row for user "([^\"]+)"/
      [:css, '[data-is=kor-users] tr', {text: $1}]

    when /the row for kind "([^\"]+)"/
      [:css, '[data-is=kor-kinds] tr', {text: $1}]

    when /the row for field "([^\"]+)"/
      [:css, 'kor-fields li', {text: $1}]

    when /the row for generator "([^\"]+)"/
      [:css, 'kor-generators li', {text: $1}]

    when /widget "([^\"]+)"/
      name = $1
      [:css, "#{name}, [data-is=#{name}]"]

    # when /the row for "([^\"]+)" "([^\"]+)"/
    #   object = $1.classify.constantize.find_by_name($2)
    #   [:css, "##{$1}_#{object.id}"]

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #  when /the (notice|error|info) flash/
    #    ".flash.#{$1}"

    # You can also return an array to use a different selector
    # type, like:
    #
    #  when /the header/
    #    [:xpath, "//header"]

    # This allows you to provide a quoted selector as the scope
    # for "within" steps as was previously the default for the
    # web steps:
    when /^the first relation on the page$/
      [:css, ".relation"]
    when /"(.+)"/
      $1
    else
      raise "Can't find mapping from \"#{locator}\" to a selector.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(HtmlSelectorsHelpers)
