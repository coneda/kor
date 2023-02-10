# ConedaKOR Development Documentation

This is a short introduction to the ConedaKOR Source-Code as well as the
functionality its APIs exposes.

Often, it is not necessary to modify the Source to achieve the desired result.
For example, to visualize data in a different way than the default frontend
provides, writing a html component and having it interact with ConedaKOR's
JSON API is sufficient. On the other hand, making changes to the way data is
handled internally requires modifications to the source code.

- [Code Architecture](#code-architecture)
  * [Backend](#backend)
  * [Frontend](#frontend)
  * [APIs](#apis)
    + [JSON](#json)
    + [OAI-PMH](#oai-pmh)
- [Generating docker images](#generating-docker-images)
- [Development Tooling](#development-tooling)
  * [Showing media in development](#showing-media-in-development)
  * [Running the test suites](#running-the-test-suites)
  * [Coverage reports](#coverage-reports)
  * [Profiling](#profiling)

## Code Architecture

ConedaKOR is a [Ruby on Rails](https://rubyonrails.org) application at its core.
It therefore interacts with a database through its models (`app/models`),
handles incoming requests with controllers (`app/controllers`) and renders
responses from a set of views (`app/views`).

The frontend is implemented as a set of web components with the help of
[riot.js](https://riot.js.org). This is why the views are not used to render
HTML. The Rails application (the backend) instead responds with JSON that the
components use to render the frontend in the browser. This separation has a
couple of consequences:

* There is no tight coupling between the frontend and the backend, so they can
  be changed independently.
* Rendering HTML is relatively slow and (when done in the backend) entails
  serialization and deserialization. Shipping only JSON to the browser
  shifts the load away from the server and distributes it to each client
  computer which usually scales well.
* Since the frontend interacts with the backend only by means of APIs, all
  functions the frontend provides can also be used through the APIs alone.
* Changing, adding or removing functionality may require changing the backend,
  the frontend or both. Particularly, changes to the look & feel can be made in
  the frontend without any understanding of the Rails application's internals.

### Backend

**Configuration** is managed with Kor::Settings: The class writes a YAML file
to persist the configuration. **Setup configuration** (without which the app
won't start), is read from environment variables, see `.env.example`.

**Authentication and authorization** are handled in controller parents for each
section of the application, so for most controllers that's `JsonController`. In
the derivative controllers, these rules are enforced by the means of "before
actions". When object-level authorization is used, it is implemented within the
derivative controllers directly, see for example `EntitiesController`.

**Database interaction** happens in the models (one class per database table)
making heavy use of Rails database associations and callbacks. For example:
While creating and updating relationships is done with `Relationship` (a
undirected graph, in a sense), behind the scenes `DirectedRelationship` is used
to synchronize a second table as a directed graph. Then, when reading, we are
reading from the directed graph (see `RelationshipsController` and
`DirectedRelationshipsController`).

Some administrative tasks are available in **Kor::Tasks**. They can be called
programmatically or (with the help of `Kor::CommandLine`) with the ConedaKOR
executable (for example `bundle exec bin/kor reset-admin-account`)

**Elasticsearch** is populated with the help of model callbacks. `Kor::Elastic`
holds mappings, settings, tasks and encapsulates the interaction with the
indexing server. The data is fully redundant and elasticsearch doesn't need to
be backed up or kept redundant. Should it not be in sync for some reason, a task
can be used to re-index all data (see above).

**Media processing** happens with
[kt-paperclip](https://github.com/kreeti/kt-paperclip) which has built-in
support for an array of image formats, see also
[imagemagick](https://imagemagick.org). Support for further file types, like
video, can be added in `lib/paperclip_processors`. Media transformation
(rotating, flipping etc.) can be added in `lib/media/transformations`.

ConedaKOR includes two **test suites**, a unit test suite (`spec`) and a e2e
test suite (`features`). Together, they provide a test coverage of 85% or
more. See below how to run the tests.

### Frontend

The frontend is implemented as a npm package using riotjs, sass and zepto. All
frontend code can be found in the `widgets` directory.

Refer to the `"scripts"` section within `package.json` for an overview of
frontend build steps.

The main functionality is implemented as riot components. Some of the components
take ownership of the url fragment when mounted and therefore provoke or listen
to changes. The format of the fragment is kept in the form of `#<path>?<query>`
which allows packing complex data structures within the url fragment. In general
the path determines which component is being mounted and the query can
optionally relay parameters to the component. For more details, refer to
`widgets/lib/routing.js.coffee`.

All styles are coming together at the `widgets/app.scss` file where all other
stylesheets are loaded from. This is also where css properties can be defined
to set up the color scheme.

### APIs

ConedaKOR ships with two APIs, a JSON api and a OAI-PMH repository. The JSON API
is best suited for application development, for example when implementing custom
frontend functionality or visualizations. OAI-PMH was designed for structured
data exchange between data repositories and is therefore a good fit for any kind
of archival.

#### JSON

The API's documentation is extensive so we gave it it's own place and made it
part of ConedaKOR itself, please refer to the api documentation. It is available
with each ConedaKOR installation since version 5, for example:

https://kor.example.com/api

#### OAI-PMH

ConedaKOR spawns four OAI-PMH endpoints for entities, kinds, relations and
relationships:

* https://kor.example.com/oai-pmh/entities?verb=Identify
* https://kor.example.com/oai-pmh/kinds?verb=Identify
* https://kor.example.com/oai-pmh/relations?verb=Identify
* https://kor.example.com/oai-pmh/relationships?verb=Identify

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

## Generating docker images

With docker installed, `docker-compose build` can be used to build docker images
for commits >= v5.0.0. The command Will build a production image based on the
current commit. This also builds the frontend.

See our (Docker Setup Guide)[#docker.md] for details on how to use the image.

## Development Tooling

The easiest way to get started hacking on kor, is to use the included vagrant
environment. Make sure vagrant and VirtualBox are installed:

* install VirtualBox (https://www.virtualbox.org/)
* install vagrant (https://www.vagrantup.com/)

Also, install the guest additions plugin:

    vagrant plugin install vagrant-vbguest

Then bring up the vagrant VM:

    vagrant up dev

SSH into the resulting VM and start the KOR development server:

    vargant ssh
    cd /vagrant
    bundle exec rails s -b 0.0.0.0

This uses the code from the current working directory on your dev machine. Go to
http://localhost:3000 with your browser to see the development page. As with all
new installations of ConedaKOR, you can login with user `admin` and password
`admin`.

Depending on the branch/commit you are using, this may or may not have a working
frontend. To ensure a frontend that is in line with the current source code
version, open a second terminal and run

    vargant ssh
    cd /vagrant
    npm run dev

This will watch the web components directory and rebuild the frontend when
changes occur.

### Showing media in development

In the development environment, images are not being shown. Instead, a icon
representing the medium's content_type is displayed. If you'd like to see the
actual images nevertheless, use

    SHOW_MEDIA=true bundle exec rails s -b 0.0.0.0

### Running the test suites

There are two test suites, rspec unit tests and cucumber integration tests.
Change to the /vagrant directory within the dev VM first and then run
the unit tests:

    bundle exec rspec spec/

or the integration tests:

    bundle exec cucumber features/

Be aware that this will spawn a real browser to conduct the tests, If you prefer
headless testing, you may use headless firefox by setting an environment
variable:

    HEADLESS=true bundle exec cucumber features/

Some tests have external dependencies and are therefore unreliable. We excluded
them from the default test suite. To force running them, set an environment
variable like this:

    KOR_BRITTLE=true bundle exec rspec spec/

### Coverage reports

You may run rspec or cucumber tests with the `COVERAGE` environment variable
set, which will generate a coverage report to `./coverage`. For example:

    COVERAGE=true HEADLESS=true bundle exec cucumber features/

### Profiling

ConedaKOR will generate a detailed per-action profile when the environment
variable PROFILE is set, for example in development:

    PROFILE=true bundle exec rails s

The reports will be generated in `./tmp/profiles`
