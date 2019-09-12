# Changelog

This log has first been created for version `1.9.1`. Also, only feature changes
and other major modifications are listed here in order to give a short overview
of every version. For earlier versions and more detail, please consult the
commit history and the closed issues on GitHub.

## Version 4.0.0

### User

This is a major release with many bug fixes, new features and some removed
features. For all the details please refer to the
[milestone summary](https://github.com/coneda/kor/milestone/9?closed=1). Here
are some highlights:

* the elasticsearch query_string syntax is now available to users via the
  "Terms" field
* changing permissions for all personal collections has been dropped in favor
  of more fine grained control
* the JSON api is finished
* deployment configuration is now handled entirely by environment variables
  (or .env files) while behavior can now be changed with the web interface
* users can't specify their start page anymore
* option to add custom css has been changed to require a url. Hosting of the
  file is now the user's responsibility.
* removed the widgets functionality from the documentation: The frontend is now
  uniformly implemented as widgets but they are not standalone. This requires
  more work to become a feature.
* given the facilitated install and configuration process, VirtualBox vms are
  not built anymore for every release. They can still be built and the scripts
  will be maintained
* angularjs was dropped in favor of riotjs. As a result generator directives
  have to be changed to use the new syntax, e.g.
  ~~~html
  <span ng-if="entity.dataset.gnd_id">{{entity.dataset.gnd_id}}</span>
  ~~~
  becomes
  ~~~html
  <span if={entity.dataset.gnd_id}>{entity.dataset.gnd_id}</span>
  ~~~

## Internal

* the web frontend is now fully migrated to riot.js.
* db sessions and exception logs have been removed along with their respective
  command line maintenance tasks
* upgraded to rails 5.0.7.1
* setting `DEBUG_FAILED=true` while running the cucumber test suite will drop
  to a `pry` session on test failures

## Version 3.0.2

This is just a bugfix release, for details see the [milestone summary](https://github.com/coneda/kor/issues?utf8=%E2%9C%93&q=is%3Aissue+milestone%3Av3.0.2+).

## Version 3.0.1

This is just a bugfix release, for details see the [milestone summary](https://github.com/coneda/kor/issues?utf8=%E2%9C%93&q=is%3Aissue+milestone%3Av3.0.1+).

## Version 3.0.0

### User

* relations can now be inverted and merged
* kinds and relations can now have semantical parents/children. This is to
  prepare cross-installation data migrations and reference model compliance
* kinds and relations can be set to be `abstract` which removes them from the
  interface but allows them to be used for semantical inheritance.
* relations can now only define one source and one target entity type
  (IMPORTANT: check https://github.com/coneda/kor/issues/94 for migration
  implications)
* added reproducible uuids when importing the Erlangen CRM
* mirador from http://projectmirador.org/ is now integrated, also via drag&drop
* 'vor 1883' is now recognized as a valid dating (resulting in an actual date
  range of 1870-01-01 to 1883-12-31), also 'nach 1883', 'nicht vor 1883', 
  'nicht nach', 'um 1883', 'circa 1883' are possible.
* added new field type for multi-line text
* added new search documentation, generously provided by the excellent [Maya
  Image Archive](https://classicmayan.kor.de.dariah.eu)
* the piwik/matomo integration now uses cookie-free tracking

### Internal

* added lockr.js for localStorage

## Version 2.1.2

### User

* video playback now works with the Safari desktop browser and on iOS devices
* maximum background processing time has ben extended to 10 hours for lengthy
  video encoding tasks
* avconv is no longer supported, it doesn't allow mp4 baseline settings and
  therefore produces videos incompatible with iOS devices
* extended vagrant environment to expose mysql and elasticsearch

### Internal

* implemented Range header handling for media retrieval

## Version 2.1.1

### User

* for authentication with an api key via request headers, header name has to be
  dashed, so `api-key`, `Api-Key` or `API-KEY` instead of `api_key`
* most parts of OAI-PMH responses are now cached which should enhance
  performance greatly
* added reference implementation for OAI-PMH client
* added JSON API endpoints to import wikidata items including properties

## Version 2.1.0

### User

* when access is denied there is no more redirect, which makes the page linkable
* OAI-PMH responses now all fully support deleted records à la
  `<deletedRecord>persistent</deletedRecord>`
* relationships may now have one or more date ranges
* the legal and about pages don't include a fixed headline anymore, this should
  be included within the configured text
* compatibility with elasticsearch 5.1
* increased full index speed by using elasticsearch bulk api
* simple search now sorts on degree of connectivity when score is equal
* kinds and relations can now have parents allowing a semantic hierarchies (e.g.
  for mapping to CIDOC CRM implementations)
* environment authentication now allows to specify a `mail` attribute and
  a `domain` attribute, the latter overriding the former
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