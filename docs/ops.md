# ConedaKOR documentation | System administrators

[Moritz Schepp](https://orcid.org/0000-0003-4237-816X)(Writing – original draft)
[Thorsten Wübbena](https://orcid.org/0000-0001-8172-6097) (Validation)


This is the ConedaKOR system administrator's guide. It covers system requirements, installation, updates and maintenance. Since most of the tasks we are discussing here are happening on the command line, we are assuming some familiarity with the linux terminal and the linux ecosystem in general.

- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Authentication](#authentication)
  * [Unauthenticated access](#unauthenticated-access)
  * [Permission inheritance](#permission-inheritance)
  * [External authentication](#external-authentication)
  * [Authentication via request env](#authentication-via-request-env)
- [Backups](#backups)
- [Restore](#restore)
- [Updates](#updates)
- [Other maintenance](#other-maintenance)
  * [Cron jobs](#cron-jobs)
  * [Logging](#logging)
- [Command line interface](#command-line-interface)
  * [Excel import and export](#excel-import-and-export)
  * [Importing Erlangen CRM classes](#importing-erlangen-crm-classes)
  * [Rebuilding elastic index](#rebuilding-elastic-index)
  * [Admin account](#admin-account)

## Requirements

ConedaKOR is a web application written with (Ruby on Rails)[https://rubyonrails.org] and it relies on MariaDB (or MySQL) and Elasticsearch for data storage and search. We also recommend setting up Apache as a reverse proxy. We will need the following components:

* 2 CPUs and 4GB RAM for most installations (recommendation)
* 30GB (linux and ConedaKOR) plus whatever amount of media you will store (recommendation)
* A exclusive DNS domain pointing to the server's ip
* A Linux installation: We are testing with Debian (currently version 11 "bullseye"). We expect ConedaKOR to work just fine with other distributions.
* A MTA (compatible with sendmail)
* Ruby and development headers:
* MariaDB
* MariaDB client and development headers
* Apache
* The apache passenger module
* imagemagick
* ffmpeg
* Elasticsearch 5.6.16 (we install this manually)

Unless otherwise stated, all commands are to be run **as root**. We will also assume that you registered the domain **kor.example.com**.

We first ensure these: On Debian, we can provide almost all of that with the APT package manager. We also include pwgen (to generate secrets later on), git-core (for dependencies installed directly from GitHub) and build-essential (to compile ruby gems written in C), so we run:

``` shell
apt-get install ruby ruby-dev apache2 libapache2-mod-passenger mariadb-server default-libmysqlclient-dev default-mysql-client default-jre ffmpeg imagemagick pwgen git-core build-essential 

```

We create a dedicated user to run ConedaKOR itself as well as Elasticsearch:

``` shell
useradd -m app
```

We also prepare the Database, we type `mysql` to use the MariaDB console and then we add permissions for new database user:

```
grant all on kor.* to 'kor'@'localhost' identified by 'kor';
exit
```

Since we are using apache, we activate the passenger module, deactivate the default site and add our own:

``` shell
a2enmod passenger
a2dissite 000-default
nano /etc/apache2/sites-available/kor.conf
```

When the editor opens, add the following content and then press `CTRL-x` and then `y`:

```
<VirtualHost *:80>
  ServerName kor
  DocumentRoot /var/rack/kor/current/public

  <Location />
    Require all granted
  </Location>
</VirtualHost>
```


We can now activate the configuration

``` shell
a2ensite kor
```

To install Elastisearch, we download it from elastic.co, extract it and configure it:

``` shell
cd /opt
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.6.16.tar.gz
tar xzf elasticsearch-5.6.16.tar.gz
mv elasticsearch-5.6.16 elastic
rm elasticsearch-5.6.16.tar.gz
cd elastic
nano config/jvm.options
```

When the editor opens, look for the two lines `-Xms1g` and `-Xmx1g`, change them to look like following snippet and then press `CTRL-x` and then `y`:

```
-Xms1g
-Xmx1g
```

Now, we give all the files in the `elastic` directory to our new `app`. We also add a configuration for systemd so that elasticsearch is started on boot and restarted when it crashes:

chown -R app: .
nano /etc/systemd/system/elastic.service

When the editor opens, add the following content and then press `CTRL-x` and then `y`:

```
[Unit]
Description=elastic service

[Service]
ExecStart=/opt/elastic/bin/elasticsearch
User=app

[Install]
WantedBy=multi-user.target
```

Now, we can enable and start it:

``` shell
systemctl enable elastic
systemctl start elastic
```

## Installation

With all the requirements installed and configured, we can proceed with installing ConedaKOR to `/var/rack/kor`:

``` shell
mkdir -p /var/rack/kor
chown app: /var/rack/kor
```

We recommend setting up a directory structure as follows. This makes updates a lot easier later on. It also makes it more clear what parts need to be included in backups and other maintenance tasks:

```
/var/rack/kor/
- current -> releases/v4.1.0
- shared/
- releases/
  - v4.1.0
```

The `current` symlink will always reference the current version in `releases`, `shared` will hold everything that needs to be kept when updating ConedaKOR. So we continue **as user app**:

``` shell
cd /var/rack/kor
mkdir shared
mkdir shared/log
mkdir releases
wget https://github.com/coneda/kor/archive/refs/tags/v4.1.0.tar.gz
tar xzf v4.1.0.tar.gz
mv kor-4.1.0/ releases/4.1.0
rm v4.1.0.tar.gz
ln -sfn /var/rack/kor/releases/4.1.0 /var/rack/kor/current
ln -sfn /var/rack/kor/shared/log /var/rack/kor/current/log
```

ConedaKOR is configurable via environment variables. We can set these however we
want but we can also use a `.env` file and set them there (**as user app**):

``` shell
cp current/.env.example shared/env
ln -sfn /var/rack/kor/shared/env /var/rack/kor/current/.env
nano shared/env
```

When the editor opens, add the following content and then press `CTRL-x` and
then `y` (for SECRET_KEY_BASE, generate a key with `pwgen 64 1`, it will have 64
characters), so **as user app**:

```
ROOT_URL="http://kor.example.com"
DATABASE_URL="mysql2://kor:kor@127.0.0.1:3306/kor?encoding=utf8&collation=utf8_general_ci&reconnect=true"
DATA_DIR="/var/rack/kor/shared/data"
SECRET_KEY_BASE=<generate me with pwgen>
```

We can now install all required ruby gems and initialize the database (**as user
app**):

cd current
bin/bundle config set --local path /var/rack/kor/shared/bundle
bin/bundle config set --local without 'development:test'
bin/bundle install

RAILS_ENV=production bin/bundle exec rake db:setup
RAILS_ENV=production bin/bundle exec bin/kor index-all

Now, we can enable and start apache:

systemctl enable apache2
systemctl start apache2

With that, ConedaKOR should be available at http://app.example.com

## Configuration

The `.env.example` file we copied earlier has many configuration settings,
please refer to the file's comments for documentation on every setting.

The configuration file in fact just sets environment variables which you can
also set elsewhere, for example in your apache VirtualHost:

~~~apache
  SetEnv "DATABASE_URL" "mysql2://<user>:<password>@..."
~~~

## Authentication

On new installations, the default user is `admin` with password `admin`. He has
all permissions to grant permissions and administer the installation. Also, he
is member of the `Administrators` credential which allows him to see and edit
all data.

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


## Backups

As per the setup above, all data is either stored in the MariaDB database or the
file system under `/var/rack/kor/shared`. Producing a consistent snapshot can be
done by:

* stopping Apache so that no more changes can be made to the data
* dump the database to `/var/rack/kor/shared`
* run a backup of `/var/rack/kor/shared` (or better `/var/rack/kor`)
* start Apache again to resume normal operations

Also, if you don't save the source code of ConedaKOR with your backup, store the
version last used.

We recommend a backup solution using (rsync)[https://rsync.samba.org/] or
(borgbackup)[https://www.borgbackup.org/]. If you are concerned that the
downtime during backups might be too long, please have a look at copy-on-write
systems on file system or block device level, for example
(btrfs)[https://btrfs.wiki.kernel.org/] or (lvm)[https://sourceware.org/lvm2/].
With that, Apache can usually be restarted after less than a second.

## Restore

To restore from a previous backup

1. restore data (and potentially the config file) from the backup
2. import the database dump
3. deploy the relevant version of ConedaKOR
6. refresh the elasticsearch index: 
   `RAILS_ENV=production bundle exec bin/kor index-all`

## Updates

Given the above directory structure, updates are straight forward:

* make a backup
* make sure the new version is compatible with your current system and install
  the new requirements
* download the new version from GitHub (e.g. v5.0.0)
* extract it to `/var/rack/kor/releases/5.0.0`

Then, we recreate the symlinks and install new dependencies. We also migrate the
database and reindex the data (**as user app**):

```
cd /var/rack/kor/releases/5.0.0
ln -sfn /var/rack/kor/shared/env .env
ln -sfn /var/rack/kor/shared/log log

cd ../..
ln -sfn /var/rack/kor/releases/5.0.0 current

cd current
bin/bundle config set --local path /var/rack/kor/shared/bundle
bin/bundle config set --local without 'development:test'
bin/bundle install

RAILS_ENV=production bundle exec rails db:migrate
RAILS_ENV=production bin/bundle exec bin/kor index-all
```

That should be it.

## Other maintenance

We compiled a couple of routine maintenance tasks and concerns that we think
might be helpful:

### Cron jobs

We recommend running a couple of tasks every night. Here is an example crontab
file:

```
# Check that entities flagged as "invalid" are indeed still "invalid" (only relevant after scripted imports)
12 1 * * * app cd /var/rack/kor/current && RAILS_ENV=production bundle exec bin/kor recheck-invalid-entities
# Delete expired download records (and zip files)
22 1 * * * app cd /var/rack/kor/current && RAILS_ENV=production bundle exec bin/kor delete-expired-downloads
# Notify users about their upcoming account expiry
42 1 * * * app cd /var/rack/kor/current && RAILS_ENV=production bundle exec bin/kor notify-expiring-users
# Re-index all entities
12 2 * * * app cd /var/rack/kor/current && RAILS_ENV=production bundle exec bin/kor index-all
```

### Logging

Log messages are sent to `log/production.log`. The log level can be configured
in `config/environments/production.rb`.

The file will likely grow fast. We can use logrotate to make it more manageable,
here is a example config file (e.g. to be stored as `/etc/logrotate.d/kor`):

```
"/path/to/kor/log/*.log" {
  missingok
  daily
  # size 100M
  rotate 60
  compress
  sharedscripts
  postrotate
    touch /path/to/kor/tmp/restart.txt
  endscript
}
```

## Command line interface

The kor command provides access to functionality which is not easily provided 
from a web page. For example, the excel export potentially generates many large
files which are impractical to download. You may call the command like
this

    bundle exec bin/kor --help

from within the ConedaKOR installation directory to obtain a detailed
description of all the tasks and options.

In the following, we describe some of these tasks in more detail

### Excel import and export

Please refer to the command line tool for available command line options. In
principle, the export produces several spreadsheets containing all entities.
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

### Admin account

The default admin account is called "admin" and has the default password
"admin". Should you lose access to your admin credentials, you can reset them to
the defaults with (**as user app**)

```
cd /var/rack/kor/current
RAILS_ENV=production bundle exec bin/kor reset-admin-account
```
