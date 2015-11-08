# ConedaKOR #

ConedaKOR allows you to store arbitrary documents and interconnect them with
relationships. You can build huge semantic networks for an unlimited amount of
domains.

To learn more and for installation instructions, please visit our
[our website (German)](http://coneda.net/pages/download)

## Changelog

We keep it updated at [CHANGELOG.md](CHANGELOG.md)

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
* Many configurable aspects (welcome page, terms of use, help, primary
  relations, brand, …)
* Access data via an OAI-PMH interface


## Documentation

These instructions are intended for system operators who wish to deploy the 
software for their users.

### Deployment

Before we go into the details of the deployment process, **please be sure to
backup the database and the `$DEPLOY_TO/shared` directory**. In practice, this
is achieved by dumping the database to a file and creating a snapshot of the VM
that contains the above directory.

ConedaKOR includes a deployment script `deploy.sh` that facilitats installs and
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

### Authentication

On new installations, the default user is `admin` with password `admin`. He has
all permissions to grant permissions and administer the installation. Also, he
is member of the `Administrators` credential which allows him to see and edit
all data.

A `guest` user can be created. If he exists, his permissions apply for
unauthenticated users. If he doesn't exist, the app will require authentication.

Authentication is performed via a web form at http://kor.example.com/login or by
providing a valid `api_key` as `GET` or `POST` parameter. You may also specify a
header `api_key` containing the key. Every user has a key which can be looked up
by an administrator on the user's administration page.

Users can be authenticated by records within the connected database system. Such
users have to be created manually by another user with the "User admin" access
right.

Additionally, one or more scripts may be written to carry out authentication
with the credentials provided by the user from the login form. This allows
flexible authentication via external sources such as PAM, LDAP or
ActiveDirectory.

Database users take preceedence before users authenticated via a script.

The script can be written in the language of your choice. Username and password
are passed to on to it through two environment variables `KOR_USERNAME_FILE` and
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
            script: /path/to/simple_auth.sh
            map_to: simple_user
          ldap:
            script: /path/to/ldap_auth.pl
            map_to: ldap_user


### API

ConedaKOR spawns two OAI-PMH endpoints for entities and relationships:

* http://kor.example.com/api/oai-pmh/entities.xml?verb=Identify
* http://kor.example.com/api/oai-pmh/relationships.xml?verb=Identify

Please refer to the [OAI-PMH
specification](https://www.openarchives.org/OAI/openarchivesprotocol.html) for
further information on available verbs and on how to use them.

The api will retrieve data tailored to the authenticated user's permissions.
Please check out [Authentication](#authentication) for how to use an api key.


### Import and export

Please refer to the command line tool.

### Command line tool

The kor command provides access to functionality which is not easily provided 
from a web page. For example, the excel export potentially generates many large
files which are impractical to download. You may call the command like
this

    bundle exec bin/kor --help

from within the ConedaKOR installation directory to obtain a detailed
description of all the tasks and options.
