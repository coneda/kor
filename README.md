# ConedaKOR #

ConedaKOR allows you to store arbitrary documents and interconnect them with
relationships. You can build huge semantic networks for an unlimited amount of
domains. This integrates a sophisticated ontology management tool with an easy
to use media database.

To learn more and for installation instructions, please have a look at the
feature list below or visit
[our website (German)](http://coneda.net/pages/download)

## Changelog

We keep it updated at [CHANGELOG.md](CHANGELOG.md)

## User documentation

Please check out our [DOCS.md](DOCS.md)

## License ##

see file COPYING

## Features ##

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
* a growing javascript widget library allowing easy integration into other apps


## Documentation

These instructions are intended for system operators who wish to deploy the 
software for their users.

### Requirements

* ruby (>= 2.1.0)
* mysql server (>= 5.5)
* elasticsearch (>= 1.7.2)
* web server (optional but highly recommended)

### Deployment

Before we go into the details of the deployment process, **please be sure to
backup the database and the `$DEPLOY_TO/shared` directory**. In practice, this
is achieved by dumping the database to a file and creating a snapshot of the VM
that contains the above directory.

ConedaKOR includes a deployment script `deploy.sh` that facilitates installs and
upgrades via SSH. It is a plain bash script that connects to the server
remotely, deploys the code to the specified directory and runs the necessary
tasks (compiling assets, starting background jobs, …). The functionality does
not include the installation of requirements, provisioning of a database server
nor the setup of a web server, since those differ greatly from server to server.

The script expects a directory `$DEPLOY_TO` on the server where it has write
permissions. Within, it will create two subdirectories `$DEPLOY_TO/releases` and
`$DEPLOY_TO/shared`. For every deployment, a subdirectory will be created within
`releases` containing the ConedaKOR code. Data that is supposed to remain
unchanged by deployments resides in `$DEPLOY_TO/shared`. Symlinks are used to
connect the current code with the permanent data. Finally, a symlink
`$DEPLOY_TO/current` will point to the current code so that your (e.g.
passenger) web server configuration can use `DEPLOY_TO/current/public` as
document root.

The script is configured by a config file `deploy.config.sh`, which could look
something like this:

    #!/bin/bash

    export KEEP=5
    export PORT="22"

    function instance01 {
      export HOST="app@node01.example.com"
      export PORT="22"
      export DEPLOY_TO="/var/storage/host/kor"
      export COMMIT="v1.9"
    }

    function instance02 {
      export HOST="deploy@node02.example.com"
      export DEPLOY_TO="/var/www/rack/kor"
      export COMMIT="master"
    }

HOST, PORT and DIRECTORY are self-explanatory. COMMIT defines the commit, branch
(head) or tag that is going to be deployed and KEEP let's you configure how many
previous deployments are going to be kept.

`deploy.config.sh` is run by the `deploy.sh` using the first parameter passed to
itself, so a call

    ./deploy.sh instance02

would deploy to instance02 according to the configuration above. On terminals 
that support it, the output is colorized according to the exit code of every
command issued by the script.

This will also start the background process that converts images and does other
heavy lifting. However, this does not ensure monitoring nor restarting of that
process which can be done for example with upstart scripts or systemd.

### Database and elasticsearch

For normal operation, ConedaKOR requires an mysql and elasticsearch instances to
be running and reachable via network. The connection specifics can are
configured in `config/database.yml`. Here is an example taken from
`config/database.yml.example`:

    production:
      adapter: mysql2
      host: 127.0.0.1
      database: kor
      username: kor
      password: kor
      encoding: utf8
      collation: utf8_general_ci
      reconnect: true

      elastic:
        host: 127.0.0.1
        port: 9200
        index: kor
        token: <secret token>

When adding content via the web interface, ConedaKOR stores information in mysql
and elasticsearch automatically and keeps the index updated in most cases. Since
there are still some rare conditions under which the elasticsearch index is not
up to date, there is a task that regenerates it from scratch, please have a look
at the [command line tool documentation](#command-line-tool) below. The optional
token will be sent as query string parameter to elasticsearch with every
request. This allows to secure it behind a proxy which denies access unless the
token is present.

### Configuration & customizations

Some aspects of ConedaKOR can be tuned to your specific needs. This sections
explains those aspects and tells you how to modify configuration options in
general.

All configuration options can be set via YAML configuration files:

  * `config/kor.defaults.yml`: You should never modify this file but it is a
    good reference for available options
  * `config/kor.yml`: this is the place for your changes
  * `config/kor.<env>.yml`: here, developers can make environemnt-specific
    overrides, for example for testing
  * `config/kor.app.<environment>.yml`: this holds configuration changed from
    within the web interface, see below.

Files further down in that list override values from above. The files' content
is generally organized under the keys development, production, test or all,
designating one or all environments they apply to. Within this documentation, we
will refer to specific options by their key. After changing the YAML
files, be sure to restart the application for the changes to take effect.

Some options can be configured via web interface: As an admin, navigate to 
`Administration -> General` and then to one of the sub sections.

#### Specific configuration options

* `custom_css [path, default: data/custom.css]`: if you specify a file 
  here and given it exists, it will be included as a customized stylesheet after
  all other style sheets. The file has to be readable by the web server. This 
  allows you to change the entire graphical design of ConedaKOR. To make this
  file persist across upgrades, we recommend to choose a path below `data/`
  which is usually symlinked to a permanent location.
* `max_results_per_request [integer, default: 500]`: the maximum allowed
  page size when requesting multiple items via JSON.
* `max_included_results_per_result [integer, default: 4]`: the maximum allowed
  page size items related to the requested one. If only a single item is
  requested, `max_results_per_request` applies instead.

### Backups

Backups consist of

* a database dump file
* a copy of all configuration files
* a copy of all data files containing your media and downloads (the data/
  directory)
* a reference to the version of ConedaKOR

All other parts of the installation directory are either considered **source
code** or **temporary**. Temporary files can be regenerated via a task. If you
made modifications to the source code, you may have to backup those as well. We
recommend to only modify the source code if those modifications are embedded
within a development process that includes regular reconsiliation with upstream.

For a consistent backup, you should aim to create the dump and file copies at
the same point in time (or at least be confident that little changes happened in
between). The dumpfile is created with mysqldump and the files can simply be
copied with `cp` or `rsync`. The configuration files to be taken into account
are:

* kor.*.yml
* config/contact.txt (if it exists)
* config/legal.txt (if it exists)
* help.yml (if it exists)
* database.yml (this is deployment-specific, it depends on your scenario
  whether it makes sense to include this in backups)
* config/secrets.yml (deployment-specific: if this file has to be regenerated,
  all current user sessions will be lost when the application is restored from a
  backup, which is acceptable in most cases)

If you used the deployment script described above, it creates a "shared"
directory and symlinks the data and the configuration from that directory to the
current deployment's directory. In this case, it is sufficient to backup the
shared folder and to create a database dump.

#### Restore

To restore from a previous backup

1. restore data and config files from the backup
2. import the database dump and modify config/database.yml accordingly if needed
3. deploy the relevant version of ConedaKOR
4. if not using `deploy.sh`, compile all assets:
   `RAILS_ENV=production bundle exec rake assets:precompile`
5. regenerate config/secrets.yml if it's missing:
   `RAILS_ENV=production bundle exec bin/kor secrets`
6. refresh the elasticsearch index: 
   `RAILS_ENV=production bundle exec bin/kor index-all`


### Authentication

On new installations, the default user is `admin` with password `admin`. He has
all permissions to grant permissions and administer the installation. Also, he
is member of the `Administrators` credential which allows him to see and edit
all data.

Authentication is performed via a web form at http://kor.example.com/login or by
providing a valid `api_key` as `GET` or `POST` parameter. You may also specify a
header `api_key` containing the key. Every user has a key which can be looked up
by an administrator on the user's administration page.

In order to be able to create user accounts, a user needs the `User admin` role.

#### Unauthenticated access

If you create a user with the username `guest`, every unauthenticated access
will be treated as if user `guest` had made it. This gives enables you to define
exactly what permissions to grant in this case. If it doesn't exist, the app
will require authentication.

#### Permission inheritance

You may enter a parent username for every user. This way, the user will not only
be able to access the parts of the application he is allowed to himself but also
that his parent has access to.

#### External authentication

Additionally, one or more scripts may be written to carry out authentication
with the credentials provided by the user from the login form. This allows
flexible authentication via external sources such as PAM, LDAP or
ActiveDirectory.

Internal users take preceedence before users authenticated via a script.

The script can be written in the language of your choice. Username and password
are passed on to it through two environment variables `KOR_USERNAME_FILE` and
`KOR_PASSWORD_FILE` which indicate files where the values can be extracted from.
The script is expected to terminate with exit code 0 if authentication was
successful and 1 otherwise. In the positive case, a valid JSON hash has to be
written to STDOUT. The hash must contain attributes to create/update the user
record with. Only 'email' is required. A user record is created unless the
username exists.

To activate the script as authenticator, configure it within `config/app.yml`.
Optionally, the key map_to can be set. The effect is that all newly created or
updated users have their parent user set to that username. This allows to grant
users from a specific authenticator a specific set of permissions. You may
configure as many authenticators as you wish.

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

Example configuration within `config/kor.yml`:

    all:
      auth:
        sources:
          simple:
            type: script
            script: /path/to/simple_auth.sh
            map_to: simple_user
          ldap:
            type: script
            script: /path/to/ldap_auth.pl
            map_to: ldap_user

The authentication system might need to create users when they authenticate via
external sources. The above configuration would create new users and set their
parent to `simple_user` or `ldap_user` depending on which authentication source
succeeded. This allows you to grant default permissions for new users to come.

#### Authentication via request env

It is also possible to configure variables to be used for authentication based
on the request environment. A common use case are Apache authentication modules
that set the `REMOTE_USER` environment variable. An example configuration can
look like this:

    all:
      auth:
        sources:
          remote_user:
            type: env
            user: ['REMOTE_USER']
            domain: example.com
            map_to: my_user_template

This may be combined with script based authentication sources. Authentication is
only triggered on GET `/env_auth` which redirects to the login form if the
environment authentication was not successfull. The `domain` value is used to
extend the username to an email address. So for example, with the above
configuration, a user logging in as jdoe would be created with an email address
`jdoe@example.com`. Additionally, the keys mail and full_name can be specified
which would make the system update successfully authenticated users with those
attributes.

When the environment yields updated user information like a changed email
address, the user is updated automatically. However, if that update fails, the
authentication is considered unsuccessful. This behavior can be deactivated with
the config option `auth.fail_on_update_errors`.

If you configure any env auth sources, a button will appear above the login form
to notify users of that possibility. If they choose to use it, they are
redirected to `/env_auth` where the magic happens. The label for the button can
be configured with the `auth.env_auth_button_label` option.

### OAI-PMH Interface

ConedaKOR spawns four OAI-PMH endpoints for entities, kinds, relations and
relationships:

* http://kor.example.com/api/oai-pmh/entities?verb=Identify
* http://kor.example.com/api/oai-pmh/kinds?verb=Identify
* http://kor.example.com/api/oai-pmh/relations?verb=Identify
* http://kor.example.com/api/oai-pmh/relationships?verb=Identify

Please refer to the [OAI-PMH
specification](https://www.openarchives.org/OAI/openarchivesprotocol.html) for
further information on available verbs and on how to use them.

The api will retrieve entities and relationships according to the authenticated
user's permissions. Kinds and relations are available without authentication.
Please check out [Authentication](#authentication) for how to use an api key.

Two formats are available: `oai_dc` and `kor`. While the former is only
maintained to fulfill the OAI-PMH specification, the latter gives full access to
all content within the ConedaKOR installation. According to specification, you
must choose the format like so `metadataPrefix=kor` as a request parameter. The
kor format adheres to a schema we provide at

https://kor.example.com/schema/1.0/kor.xsd

as part of every installation (version 2.0.0 and above). We will add new
versions, should the need arise.

### Widgets

ATTENTION: This feature is experimental and subject to future change.

We are working on creating a complete widget library so that the entire frontend
is just a composition of widgets. Since that requires extensive refactoring of
most of the code base, this process is going to take some time. However, some
components are usable already. We will list those below and describe how they
work and extend the list continuously.

In general, widgets have the form of custom html tags. They are all prefixed
with `kor-`. There are two types: application-widgets and standalone-widgets.
The former are additionally prefixed with `app-`, the latter are not. An example
for an application-widget would thus be `<kor-app-router>` and `<kor-entity>` is
a standalone widget. The main difference is that  standalone-widgets try to be
usable outside of the ConedaKOR context, within other web applications.

To use any of the widgets, the library has to be added to the integrating page.
The best position for this is directly below the closing body tag, so for
example:

    <html>
      ...
      <body>
        ...
        <script
          src="https://kor.example.com/app.js"
          kor-url="https://kor.example.com"
        ></script>
      </body>
    </html>

In addition, you will have to list the origin in the configuration parameter
`allowed_origins` so that the CORS header is set accordingly, e.g.

    ...
      allowed_origins: ['https://kor.example.com']
    ...

The following widgets can then be used on the integrating page:

#### `<kor-entity>`

    <kor-entity
      id="<id or uuid>"
      kor-style="true"
    />

This shows the entity (also supports media entities) referenced by `id`. If you
add the `kor-style` attribute, the widget will apply some basic styling.
However, the styles will always mix with the existing styles on the page so some
CSS adjustments might be necessary. with `kor-include` you may supply a space
separated list of information to include (currently supports `kind`). The
attribute `kor-image-size` allows you to specify witch image resultion should
be loaded (icon, thumbnail, preview, screen, normal) for media.

### JSON API

This API is undergoing a lot of change. This is why we are not showing all of
the possible requests here. Instead, we'll just listing the ones that we hope
will not change anymore in the forseeable future.

The request paths all end with `.json` to hint the desired JSON content type for
the response. But also the request body has to be in the JSON format and the
request's `content-type` header has to be `application/json`

Have a look at [Authentication](#authentication) to see how you can provide
authentication credentials.

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
* `GET /entities/1/relationships.json`, or `/relationships`: returns the relationships (for that entity), returns only viewable content, returns resultset of directed relationships
    * `from_entity_id`: limits by the source entity, comma-separated
    * `to_entity_id` or `entity_id`: limits by the target entity, comma-separated
    * `relation_name`: limits by relation name, comma-separated
    * `from_kind_id`: limits by the source's kind, comma-separated
    * `to_kind_id`: limits by the target's kind, comma-separated
    * `page`: requests a specific page from the resultset (default: 1)
    * `per_page`: sets the page size (default: 10, max: 500)

Resultsets are JSON objects having this structure:

    {
      total: 133,
      page: 1,

      ids: [13,89,1333],
      records: [ ... ],
    }

while `ìds` and `records` are optional.

Be aware that, if you are requesting related entities to be embedded within
other entities, those are embedded as a list of directed relationships which
in turn contain the entity itself.

### Generating a virtual appliance

Versions after and including 1.9.2 can be packaged into a virtualbox appliance
automatically. The version is specified as a shell parameter:

    ./deploy/build.sh v1.9.2

The ova file and a checksum are generated within `deploy/build/`. Instead of
`v1.9.2` you may choose any tag or branch available in the repository, although
very old versions could not work because of unsatisfiable dependencies. Make
sure you have pulled the most recent commits when using branches!

### Generating docker images

`deploy/dockerize.sh can be used to build docker images for commits >= v2.0.0.
`Because of a different set of tools required for each environment, it has to be
`selected when building the images. For example:

    ./deploy/dockerize.sh master production

Will build a production image based on the master branch. You may also base
images on tags or commits.

### Command line tool

The kor command provides access to functionality which is not easily provided 
from a web page. For example, the excel export potentially generates many large
files which are impractical to download. You may call the command like
this

    bundle exec bin/kor --help

from within the ConedaKOR installation directory to obtain a detailed
description of all the tasks and options.

#### Excel import and export

Please refer to the command line tool for available command line options. In
principle, the export produces seceral spreadsheets containing all entities.
Those sheets may be modified and imported later on.

* identification columns (id and uuid) are not imported: they are only used to
  identify existing records on imports. Leave empty when adding new data.
* the deleted column is not imported: enter any non-empty value in order to
  delete the entity on import.
* timestamps are not imported: they will be changed if the entity will be
  changed by the import.

#### Rebuilding elastic index

Sometimes the elasticsearch index has to be rebuilt from scratch. This is done
like so:

    bundle exec bin/kor index-all

### Development

The easiest way to get started hacking on kor, is to use the included vagrant
test environment. For now, you can create it with

    vagrant up

SSH into the resulting virtual machine and start the development server:

    vargant ssh
    ...
    bundle exec rails s

This uses the code from the current working directory on your dev machine. Go to
http://localhost:3000 with your browser to see the development page.

#### Running the test suites

There are two test suites, rspec unit tests and cucumber integration tests.
Change to the /vagrant directory within the dev VM first and then run
the unit tests:

    bundle exec rspec spec/

or the integration tests:

    bundle exec cucumber features/

Be aware that this will spawn a real browser to conduct the tests, If you prefer
headless testing, you may use phantomjs by setting an environment variable:

    HEADLESS=true bundle exec cucumber features/

#### Coverage reports

You may run rspec or cucumber tests with the `COVERAGE` environment variable
set, which will generate a coverage report to `./coverage`. For example:

    COVERAGE=true HEADLESS=true bundle exec cucumber features/

#### Profiling

ConedaKOR will generate a detailed per-action profile when the environment
variable PROFILE is set, for example in development:

    PROFILE=true bundle exec rails s

The reports will be generated in `./tmp/profiles`

#### Showing media in development

In the development environment, images are not being shown. Instead, a icon
representing the medium's content_type is displayed. If you'd like to see the
actual images nevertheless, use

    SHOW_MEDIA=true bundle exec rails s
