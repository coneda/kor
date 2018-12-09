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

Then add rbenv to your shell. In the defailt debian 9 case, you could

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
