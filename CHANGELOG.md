# Changelog

This log has first been created on version `1.9.1`. Also, only feature changes
and other major modifications are listed here in order to give a short overview
of every version. For earlier versions and more detail, please consult the
commit history on GitHub.

## Version X

### Internal

* added lockr.js for localStorage

### User

* for authentication with an api key via request headers, header name has to be
  dashed, so `api-key`, `Api-Key` or `API-KEY` instead of `api_key`.
* most parts of OAI-PMH responses are now cached which should enhance
  performance greatly
* added reference implementation for OAI-PMH client

## Version 2.1.0

### User

* when access is denied there is no more redirect, which makes the page linkable
* OAI-PMH responses now all fully support deleted records à la
  `<deletedRecord>persistent</deletedRecord>`
* relationships may now have one or more date ranges
* compatibility with elasticsearch 5.1
* increased full index speed by using elasticsearch bulk api
* simple search now sorts on degree of connectivity when score is equal
* kinds and relations can now have parents allowing a semantic hierarchies (e.g.
  for mapping to CIDOC CRM implementations)
* environment authentication now allows to specify a `mail` attribute and
  a `domain` attribute, the latter overriding the former.
* resumptionToken within OAI-PMH responses now behaves according to specs

## Version 2.0.1

### User

* pagination back-button doesn't work (#2192 redmine)
* weird focus and click behaviour on pagination number input (#2183 redmine)
* initial page load somethimes leads to race condition (#2182 redmine)
* 'recently visited' tab (relationship editor) doesn't show expected entities
  (#2161 redmine). The resolution also has the side effect of the history of
  visited entities is now remembered across sessions.

### Internal

* all vms defined by vagrant now use the `bento/ubuntu-16.04` base box
* a new vagrant vm `bare` is defined that just installs requirements. This
  serves to test the deploy scripts.
* using systemd for deploying services via vagrant

## Version 2.0.0

### User

* added OAI-PMH api to enable harvesting of entities, kinds, relationships and 
  relations
* added token authentication
* dropped debian package generation
* added cli-command to cleanup old sessions
* identifier handling and resolution
* changes to field names are now propagated to affected entities
* sample data can be generated during db seeting by setting `SAMPLE_DATA=true`
* a task to display list permissions
* creating and editing relationships is now done inline
* the gallery is now rendered in the browser and is therefore a lot faster
* an HTML5 audio player is now available
* the video player has been dropped in favor of native HTML5 functionality
* some roles have been dropped: `user_admin`, `credentials_admin`,
  `collection_admin` and `developer` are now just `admin`
* environment variables like `REMOTE_USER` can now be used for authentication
* kinds now require their plural name to be specified
* email configuration removed from web-ui, site operator is used as sender and
  email server configuration is exclusively done in the config file
* started refactoring the JSON api, see README.md
* added widget layer to facilitate integration with other websites
* made headlines and lists work within textile-enabled text fields
* the clipboard now persists beyond a user session

### Internal

* switched from rails 3.2 to 4.2
* sped up the test suites by about 20%
* identifier handling and resolution
* added VCR gem to enable testing against predictable external API responses
* added a development environment via `vagrant up`
* relationships are now saved as two records per link (in and out). This greatly
  simplyfies queries and enhances performance
* audio and video processing are now faster and adhere to the paperclip gem's
  way
* added brakeman for security audits
* added rubocop to improve code style
* media are not shown in development anymore (override with `SHOW_MEDIA`)
* included docker images build scripts for development, test and production
  images
* upgraded some gems to their most recent bugfix release
* switched from active_record_store for sessions to the cookie_store. Now
  handling history and clipboard with a serialized attribute on the user model


## Version 1.9.2

### User

* changed custom authentication to work with environment variables rather than
  with files
* made custom authentication logging more verbose
* fixed synonyms that had been saved as strings instead of an array of strings
* fixes the metadata download
* refactored the command line tool
* upgraded to ruby 2.2.3
* made searching for related entities much faster
* made loading the statistics page much faster
* added documentation for deployment
* fixes entity deletion via excel import
* fixed the switch to expand all relationships for one relation
* made deployment include symlinks to serve `icons`, `thumbnail` and `screen`
  image sizes as static files bypassing the rails stack

## Internal

* added a pagination directive for angularjs
* split the page showing an entity into multiple angularjs directives
* removed the legacy web_services code (replaced with generators)
* cleaned up the lib directory to comply with best practices
* dropped a lot of legacy tables

## Version 1.9.1

### User

* started maintaining a changelog
* fully replaced MongoDB with Elasticsearch
* replaced the former WebServices with fields and generators
* removed rating functionality
* command line based excel import/export
* a page showing isolated entities
* navigating from one entity to another doesn't reload the page anymore
* validation errors for unnecessary white space
* reincarnation of the feature "published groups"
* dropped web services in favor of generators

### Internal

* fully replaced machinist with factory_girl for fixture creation
* upgraded many gem dependencies like paperclip and rspec
* migrated to the rspec `expect` syntax
* using SecureRandom for generating UUIDs