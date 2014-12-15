# Changelog

This log has first been created on version `1.9.0`. Also, only feature changes
and other major modifications are listed here in order to give a short overview
of every version. For earlier versions and more detail, please consult the
commit history on GitHub.

## Version 1.9.0

### User

* started maintaining a changelog
* fully replaced MongoDB with Elasticsearch
* replaced the former WebServices with fields and generators
* removed rating functionality

### Internal

* fully replaced machinist with factory_girl for fixture creation
* migrated to the rspec `expect` syntax
* upgraded rspec to version 3.1.0