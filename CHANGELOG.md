# Changelog

This log has first been created on version `1.9.1`. Also, only feature changes
and other major modifications are listed here in order to give a short overview
of every version. For earlier versions and more detail, please consult the
commit history on GitHub.

## Version ???

### User

* dropped debian package generation
* added cli-command to cleanup old sessions
* added a development environment via `vagrant up`
* sped up the test suites by about 20%

## Version 1.9.2

### User

* changed custom authentication to work with environment variables rather than
* made custom authentication logging more verbose
  with files
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