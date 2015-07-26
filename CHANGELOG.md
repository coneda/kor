# Changelog

This log has first been created on version `1.9.0`. Also, only feature changes
and other major modifications are listed here in order to give a short overview
of every version. For earlier versions and more detail, please consult the
commit history on GitHub.

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