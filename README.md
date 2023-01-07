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
[user guide (German, for version 3)](https://github.com/coneda/kor_leitfaden_ffm/wiki)

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
