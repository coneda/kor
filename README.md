# ConedaKOR

ConedaKOR is a web based application which allows you to store arbitrary
documents and interconnect them with relationships. You can build huge semantic
networks for an unlimited amount of domains. This integrates a sophisticated
ontology management tool with an easy to use media database.


## Table of Contents <!-- regenerate with npm run toc -->

- [Table of Contents](#table-of-contents)
- [Features](#features)
- [User documentation](#user-documentation)
- [Changelog](#changelog)
- [License](#license)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Customization](#customization)
- [Logging](#logging)
- [Backups](#backups)
  * [Restore](#restore)
- [Authentication](#authentication)
  * [Unauthenticated access](#unauthenticated-access)
  * [Permission inheritance](#permission-inheritance)
  * [External authentication](#external-authentication)
  * [Authentication via request env](#authentication-via-request-env)
- [Interfaces](#interfaces)
  * [OAI-PMH](#oai-pmh)
  * [REST (JSON)](#rest-json)
- [Generating a virtual appliance](#generating-a-virtual-appliance)
- [Generating docker images](#generating-docker-images)
- [Command line tool](#command-line-tool)
  * [Excel import and export](#excel-import-and-export)
  * [Importing Erlangen CRM classes](#importing-erlangen-crm-classes)
  * [Rebuilding elastic index](#rebuilding-elastic-index)
- [Development](#development)
  * [Running the test suites](#running-the-test-suites)
  * [Coverage reports](#coverage-reports)
  * [Profiling](#profiling)
  * [Showing media in development](#showing-media-in-development)

## Features

* Instead of filling countless lists with your metadata, shape it as
  **entities** within a graph ... never repeat yourself!
* Add **relationships** between your entities
* A carefully designed user interface
* Upload any kind of **media** (pictures, video, spreadsheets, …), also many at
  a time
* Images and videos are automatically converted for playback on the web
* Define which **kind** of entities can be related by what **relations**
* Put your entities in one or many **groups** and share them with other users
* A Fine-grained permission system with **user groups** and entity
  **collections**
* Easy extension of the schema for every kind of entity: Add fields for all
  entities of a specific kind or occasionally add data to arbitrary entities
* Tagging with autocomplete and sensible permissions
* Full text search through all your metadata
* A rich API facilitating additional frontends and data harvesting
* Excel import and export
* Deliver one-click zip downloads to your users
* Identify isolated entities
* Merge entities to further normalize your data
* External authentication (for example LDAP) by simple shell scripts
* Easy identifier management and resolution
* Many configurable aspects (welcome page, terms of use, help, primary
  relations, brand, …)
* Access data via an OAI-PMH interface
* Vagrant dev environment
* good unit and integration test coverage
* checked for security problems with
  [brakeman](https://github.com/presidentbeef/brakeman)
* support for using Erlangen CRM and similar standards as basis for your
  ontology (including a convenient OWL import tool)

## User documentation

Please check out our
[user guide (German)](https://github.com/coneda/kor_leitfaden_ffm/wiki)

## Changelog

We keep it updated at [CHANGELOG.md](CHANGELOG.md)

## License

See file [COPYING](COPYING)

## Requirements

* ruby 2.4.4 (it should also run with slightly older or more recent versions
  but we only tested with 2.4.4)
* mysql server (>= 5.5)
* elasticsearch (>= 5.0.0, < 6.0.0)
* web server (optional but highly recommended)
* neo4j (optional)

## Installation

Please refer to [INSTALL.md](INSTALL.md)

## Configuration

Configuration on the server such as database connection information and data
directory can all be set as environment variables. For example, to set a
database string, you may put the following in your apache VirtualHost:

~~~apache
  SetEnv "DATABASE_URL" "mysql2://<user>:<password>@..."
~~~

If you prefer file based configuration, you may also create a file `.env` in
the kor application directory (where config.ru is located) and add the settings
there like in a bash script, for example

~~~bash
export DATABASE_URL="mysql2://<user>:<password>@..."
~~~

`export` is optional but it allows to source this file with bash, should the
need arise.

For a list of configuration options, please refer to
[.env.example](.env.example) (of the ConedaKOR version deployed).

## Customization

All customization can be done via the web interface. As an admin, follow the
"Settings" navigation link.

## Logging

Log messages are sent to `log/production.log`. The log level can be
configured in `config/environments/production.rb`.

## Backups

Backups consist of

* a database dump file
* a the configuration file `.env` (if you use one, see above)
* a copy of the data directory
* a reference to the version of ConedaKOR

All other parts of the installation directory are either considered **source
code** or **temporary**. Temporary files can be regenerated via a task. If you
made modifications to the source code, you may have to backup those as well. We
recommend to only modify the source code if those modifications are embedded
within a development process that includes regular reconsiliation with upstream.

For a consistent backup, you should aim to create the dump and file copies at
the same point in time (or at least be confident that little changes happened in
between). The dumpfile is created with mysqldump and the files can simply be
copied with `cp` or `rsync`.

If you used the scripted install, it creates a "shared" directory and symlinks
the data and the configuration from that directory to the current deployment's
directory. In this case, it is sufficient to backup the shared folder and to
create a database dump.

### Restore

To restore from a previous backup

1. restore data (and potentially the config file) from the backup
2. import the database dump and modify the configuration accordingly
3. deploy the relevant version of ConedaKOR
6. refresh the elasticsearch index (if you are using elasticsearch): 
   `RAILS_ENV=production bundle exec bin/kor index-all`

## Authentication

On new installations, the default user is `admin` with password `admin`. He has
all permissions to grant permissions and administer the installation. Also, he
is member of the `Administrators` credential which allows him to see and edit
all data.

Authentication is performed via a web form at http://kor.example.com#/login or
by providing a valid `api_key` as `GET` or `POST` parameter. You may also
specify a header `api-key` containing the key (make sure not to use an
underscore). Every user has a key which can be looked up by an administrator on
the user's administration page.

In order to be able to create user accounts, a user needs the `User admin` role.

### Unauthenticated access

If you create a user with the username `guest`, every unauthenticated access
will be treated as if user `guest` had made it. This gives enables you to define
exactly what permissions to grant in this case. If it doesn't exist, the app
will require authentication.

### Permission inheritance

You may enter a parent username for every user. This way, the user will also be
able to all the parts of the application his parent has access to.

### External authentication

Additionally, one or more scripts may be written to carry out authentication
with the credentials provided by the user from the login form. This allows
flexible authentication via external sources such as PAM, LDAP or
ActiveDirectory.

Internal users take preceedence over users authenticating via a script.

The script can be written in the language of your choice. Username and password
are passed on to it through two environment variables `KOR_USERNAME_FILE` and
`KOR_PASSWORD_FILE` which indicate files where the values can be extracted from.
The script is expected to terminate with exit code 0 if authentication was
successful and 1 otherwise. In the positive case, a valid JSON hash has to be
written to STDOUT. The hash must contain attributes to create/update the user
record. Only 'email' is required. A user record is created unless the username
exists.

To activate the script as authenticator, configure it within your environment.
Have a look at `.env.example` for examples and description of the available
options.

Example authenticator script `simple_auth.sh`:

    #!/bin/bash

    KOR_USERNAME=`cat $KOR_USERNAME_FILE`
    KOR_PASSWORD=`cat $KOR_PASSWORD_FILE`

    if [ "$KOR_USERNAME" == "jdoe" ] && [ "$KOR_PASSWORD" == "mysecret" ] ; then
      echo "{\"email\": \"jdoe@example.com\"}"
    else
      echo "{}"
      exit 1
    fi

The authentication system might need to create users when they authenticate via
external sources. The above configuration would create new users and set their
parent to `simple_user` or `ldap_user` depending on which authentication source
succeeded. This allows you to grant default permissions to new users.

### Authentication via request env

It is also possible to configure variables to be used for authentication based
on the request environment. A common use case are Apache authentication modules
that set the `REMOTE_USER` environment variable. Have a look at `.env.example`
for examples and description of the available options.

This may be combined with script based authentication sources. Authentication is
only triggered on GET `/env_auth` which falls back to the login form if the
environment authentication was not successfull.

If you configure any env auth sources, a button will appear above the login form
to notify users of that possibility. If they choose to use it, they are
redirected to `/env_auth` where the magic happens. The label for the button can
be customized via the web interface.

## Interfaces

### OAI-PMH

ConedaKOR spawns four OAI-PMH endpoints for entities, kinds, relations and
relationships:

* http://kor.example.com/oai-pmh/entities?verb=Identify
* http://kor.example.com/oai-pmh/kinds?verb=Identify
* http://kor.example.com/oai-pmh/relations?verb=Identify
* http://kor.example.com/oai-pmh/relationships?verb=Identify

Please refer to the [OAI-PMH
specification](https://www.openarchives.org/OAI/openarchivesprotocol.html) for
further information on available verbs and on how to use them.

The api will retrieve entities and relationships according to the authenticated
user's permissions. Kinds and relations are available without authentication.
Please check out [Authentication](#authentication) for how to use an api key.

Two formats are available: `oai_dc` and `kor`. While the former is only
maintained to fulfill the OAI-PMH specification, the latter gives full access to
all content within the ConedaKOR installation. According to specification, you
must choose the format as a request parameter `metadataPrefix=kor`. The
kor format adheres to a schema that is included in ConedaKOR. It can be found at

https://kor.example.com/schema/1.0/kor.xsd

as part of every installation (version 2.0.0 and above). We will add new
versions, should the need arise.

### REST (JSON)

This API is undergoing a lot of change. This is why we are not showing all of
the possible requests here. Instead, we'll just listing the ones that we hope
will not change anymore in the forseeable future.

The request paths all end with `.json` to hint the desired JSON content type for
the response. But also the request body has to be in the JSON format and the
request's `content-type` header has to be `application/json`

Have a look at [Authentication](#authentication) to see how you can provide
authentication credentials.

In general, there are three types of responses:

Requests that **retrieve a single record** will always answered with a
simple object containing just that record, e.g.

```
GET /kinds/1.json

{
  "id": 123,
  "name": "person",
  "plural_name": "people",
  ...
}
```

Requests that **retrieve a series of records** (resultsets) will always be
answered with the objects themselves but also the total number of records, the
current page and the amount of records per page. Sometimes not full records are
returned but only their ids in which case the `records` array will be empty and
there will be an `ids` array instead, e.g.

```
GET /kinds.json

{
  "records": [...],
  "total": 120,
  "per_page": 10,
  "page": 7
}
```

Requests that **modify a record** will always be answered with the modified
record as well as a message indicating the modification applied. Also the
response code will reflect a successful change (200) or incorrect new data
(422). This applies to create (POST), update (PATCH) and destroy (DELETE)
requests, e.g.

```
POST /kinds.json
with JSON {"kind": {"name": "person", "plural_name": "people"}}

{
  "message": "the kind 'person' has been created",
  "record": {
    "id": 123,
    "name": "person",
    "plural_name": "people",
    ...
  }
}
```


* `GET /kinds.json`: returns array of all kinds
* `GET /kinds/1.json`: returns kind with id 1
* `GET /relations.json`: returns array of all relations
* `GET /relations/1.json`: returns relation with id 1
* `GET /entities.json`: search for entities, returns only viewable content, returns resultset of entities
    * `terms`: searches for entities with matching name or synonyms (uses the
      elasticsearch index)
    * `relation_name`: limits to entities that can be used as targets for the
      given relation name
    * `kind_id`: limits to entities that are of the given kind
    * `include_media`: whether to include media entities (default: false)
    * `include`: a list of aspects to include within each entity, comma separated, choose one or more of `technical`, `synonyms`, `datings`, `dataset`, `properties`, `relations`, `media_relations`,`related`, `kind`, `collection`, `user_groups`, `groups`, `degree`, `users`, `fields`, `generators` and `all`.
    * `page`: requests a specific page from the resultset (default: 1)
    * `per_page`: sets the page size (default: 10, max: 500)
    * `related_kind_id`: sets a filter for kind ids on related entities
    * `related_relation_name`: sets a filter for relation names on related entities
    * `related_per_page`: sets the page size for related entities [default: 1, max: 4]
* `GET /entities/1.json`: returns the entity with id 1, requires `view` permissions for that entity
    * `include`: see parameters for `/entities.json`
    * `related_kind_id`: see parameters for `/entities.json`
    * `related_relation_name`: see parameters for `/entities.json`
    * `related_per_page`: see parameters for `/entities.json` [different max of 500]
* `GET /relationships.json`: returns the relationships, returns only viewable content, returns resultset of directed relationships
    * `from_entity_id`: limits by the source entity, comma-separated
    * `to_entity_id` or `entity_id`: limits by the target entity, comma-separated
    * `relation_name`: limits by relation name, comma-separated
    * `from_kind_id`: limits by the source's kind, comma-separated
    * `to_kind_id`: limits by the target's kind, comma-separated
    * `page`: requests a specific page from the resultset (default: 1)
    * `per_page`: sets the page size (default: 10, max: 500)
* `POST /wikidata/import`: imports a wikidata item. This also creates potential relationships towards previously imported items
    * `id`: the wikidata id of the item to import e.g. `Q762`
    * `kind`: the kind of the new entity, e.g. `person`
    * `collection`: the collection where to create the new entity (the 'create' right is required within that collection)
    * `locale`: the locale to import from wikidata, defaults to `en`
* `POST /wikidata/preflight`: simulates the previous method without actually changing any data

Be aware that, if you are requesting related entities to be embedded within
other entities, those are embedded as a list of directed relationships which
in turn contain the entity itself.

## Generating a virtual appliance

Versions after and including 1.9.2 can be packaged into a virtualbox appliance
automatically. The version is specified as a shell parameter:

    ./deploy/build.sh v1.9.2

The ova file and a checksum are generated within `deploy/build/`. Instead of
`v1.9.2` you may choose any tag or branch available in the repository, although
very old versions could not work because of unsatisfiable dependencies. Make
sure you have pulled the most recent commits when using branches!

## Generating docker images

`deploy/dockerize.sh can be used to build docker images for commits >= v2.0.0.
`Because of a different set of tools required for each environment, it has to be
`selected when building the images. For example:

    ./deploy/dockerize.sh master production

Will build a production image based on the master branch. You may also base
images on tags or commits.

## Command line tool

The kor command provides access to functionality which is not easily provided 
from a web page. For example, the excel export potentially generates many large
files which are impractical to download. You may call the command like
this

    bundle exec bin/kor --help

from within the ConedaKOR installation directory to obtain a detailed
description of all the tasks and options.

### Excel import and export

Please refer to the command line tool for available command line options. In
principle, the export produces seceral spreadsheets containing all entities.
Those sheets may be modified and imported later on.

* identification columns (id and uuid) are not imported: they are only used to
  identify existing records on imports. Leave empty when adding new data.
* when creating new records, you will have to fill in at least the columns for
  kind_id, collection_id and name (or no_name_statement). For the serialized
  columns, please use their "natural" empty value if you don't use them. So
  for dataset `{}`, for properties `{}` for synonyms: `[]` for datings: `[]`.
* the deleted column is not imported: enter any non-empty value in order to
  delete the entity on import.
* timestamps are not imported: they will be changed if the entity will be
  changed by the import.

### Importing Erlangen CRM classes

The task will import all classes from
http://erlangen-crm.org/ontology/ecrm/ecrm_current.owl, documented by
http://erlangen-crm.org/docs/ecrm/current/index.html into the installation as
entity types. The types will be set up according to their hierarchy and they
will be set to be "abstract" which prevents them from showing up in the
interface.

### Rebuilding elastic index

Sometimes the elasticsearch index has to be rebuilt from scratch. This is done
like so:

    bundle exec bin/kor index-all

## Development

The easiest way to get started hacking on kor, is to use the included vagrant
test environment. Make sure vagrant and VirtualBox are installed:

* install VirtualBox (https://www.virtualbox.org/)
* install vagrant (https://www.vagrantup.com/)

Also, install the guest additions plugin:

    vagrant plugin install vagrant-vbguest

Then bring up the vagrant VM:

    vagrant up dev

SSH into the resulting VM and start the KOR development server:

    vargant ssh
    cd /vagrant
    ...
    bundle exec rails s -b 0.0.0.0

This uses the code from the current working directory on your dev machine. Go to
http://localhost:3000 with your browser to see the development page. As with all
new installations of ConedaKOR, you can login with user `admin` and password
`admin`.

### Running the test suites

There are two test suites, rspec unit tests and cucumber integration tests.
Change to the /vagrant directory within the dev VM first and then run
the unit tests:

    bundle exec rspec spec/

or the integration tests:

    bundle exec cucumber features/

Be aware that this will spawn a real browser to conduct the tests, If you prefer
headless testing, you may use phantomjs by setting an environment variable:

    HEADLESS=true bundle exec cucumber features/

### Coverage reports

You may run rspec or cucumber tests with the `COVERAGE` environment variable
set, which will generate a coverage report to `./coverage`. For example:

    COVERAGE=true HEADLESS=true bundle exec cucumber features/

### Profiling

ConedaKOR will generate a detailed per-action profile when the environment
variable PROFILE is set, for example in development:

    PROFILE=true bundle exec rails s

The reports will be generated in `./tmp/profiles`

### Showing media in development

In the development environment, images are not being shown. Instead, a icon
representing the medium's content_type is displayed. If you'd like to see the
actual images nevertheless, use

    SHOW_MEDIA=true bundle exec rails s
