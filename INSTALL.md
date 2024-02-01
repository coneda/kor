# Installation

The easiest way to install ConedaKOR is with on Debian 9 stretch. While we will
not go into installing apache, mysql and elasticsearch, we will show how to use
rbenv to have several ruby versions available easily. Also, we will use phusion-
passenger to host ConedaKOR with apache:

This installation will work with Version v4.0 an later.

#### Prepare the OS

Make sure the OS has all updates installed. Also install the following packages,
we will need them to install ruby versions and some of the ruby gems:

~~~bash
# as root
apt-get install git-core build-essential libmariadbclient-dev \
  libcurl4-openssl-dev ruby-dev libxml2-dev libxslt-dev imagemagick \
  libav-tools zip libapache2-mod-passenger libssl-dev libreadline-dev
~~~

#### Create a User

Create a user to run ConedaKor with. We will assume a user `app`. Also make
sure the user has all permissions on a app directory. We will assume `/var/kor`:

~~~bash
# as root
useradd -m -s /bin/bash app
mkdir -p /var/kor
chown -R app. /var/kor
~~~

The following steps should all be done with that user (e.g. `su app`) unless
marked with `# as root`:

#### rbenv

Now install rbenv a plugin ruby-build (loosely following the [Basic Github
Checkout](https://github.com/rbenv/rbenv#basic-github-checkout)):

~~~bash
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
~~~

Then add rbenv to your shell. In the default debian 9 case, you could

~~~bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc
~~~

Now you should be ready to use rbenv. rbenv should show the system ruby
installation which we just installed via `apt-get install [...]
libapache2-mod-passenger`

~~~bash
rbenv versions
* system (set by /home/app/.rbenv/version)
~~~

Now install the ruby version for this ConedaKOR version (find it in
.ruby-version). This will take a minute or two:

~~~bash
rbenv install 2.4.4
~~~

After that, we activate the version (for this shell session) and install
bundler:

~~~bash
rbenv shell 2.4.4
gem install bundler
~~~

#### Copy the source & install gems

Clond the repository, check out the correct tag and install the gem
dependencies. The last step will take one or two minutes.

~~~bash
git clone https://github.com/coneda/kor.git /var/kor/app
cd /var/kor/app
git checkout v4.0.0
bundle install --without development test
~~~

#### Configure KOR & create the db

~~~bash
cp /var/kor/app/.env.example /var/kor/app/.env
~~~

Then edit the .env file to reflect your environment. A good location for your
DATA_DIR is outside the app directory since it should survive updates. We will
use `/var/kor/data`.

Now we can create the database with:

~~~bash
cd /var/kor/app
RAILS_ENV=production bundle exec rake db:setup
~~~

#### Apache

To make apache host the file we need to first change the ruby interpreter for
passenger: Change the relevant config line in
`/etc/apache2/mods-available/passenger.conf`.

~~~
# as root
...
  PassengerDefaultRuby /home/app/.rbenv/shims/ruby
...
~~~

Then enable the module

~~~bash
# as root
a2enmod passenger
~~~

With the module up and running, we can add a virtualhost file to
`/etc/apache2/sites-available/001-kor.conf` and enable it like this:

~~~
# as root
<VirtualHost *:80>
  ServerName kor.example.com
  DocumentRoot /var/kor/app/public

  <Location />
    Require all granted
  </Location>
</VirtualHost>
~~~

~~~bash
# as root
a2ensite 001-kor
~~~

If this is a fresh debian apache install, make sure to disable the default
VirtualHosts:

~~~bash
# as root
a2dissite 000-default default-ssl
~~~

~~~bash
# as root
systemctl restart apache2
~~~

#### Test

The app should now be available at http://kor.example.com. The exact location 
depends on your server and your DNS records.


# Additional

If you are deploying elasticsearch, make sure to specify its url and the index
you want to use with ConedaKOR in .env (or via the environment). Also make sure
to run

~~~bash
su app
cd /var/kor/app
RAILS_ENV=production bundle exec bin/kor index-all
~~~

To create a populate the index.

### Scripted installation

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
Also, it might be that your specific setup requires modification to the script,
for example to manage the background job, you might prefer to use a systemd,
changing the way it is restarted.

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

The first time the script is run, some default configuration files are copied to
the host. It will then stop execution and let you modify the files according to
your setup. Re-run it when done.

This will also start the background process that converts images and does other
heavy lifting. However, this does not ensure monitoring nor restarting of that
process which can be done for example with upstart scripts or systemd. The
process can be managed manually with the command (on the server):

    RAILS_ENV=production bundle exec bin/delayed_job

See `--help` for details. By default, log messages are sent to the main rails
log file.

After deployment has succeeded and you log in the first time, make sure to add
the application scheme, host and port to "Administration -> General -> Server".
This is necessary because the information can't always be inferred from all
contexts.