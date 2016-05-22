# ConedaKOR User Documentation

ConedaKOR allows you to create vast and arbitrary knowledge networks. You can do
this by simply creating objects (we call them entities) and connect them with
relationships. Both have a type: For example, there might be an entity called
`Mona Lisa` of type `Artwork` and another called `Leonardo da Vinci` of type
`Person`. Additionally, they might be related with a relationship of the type
`was created by`. This piece of information is called a triple. There might be
more entities and many more relationships forming a large network.

While ConedaKOR gives you many additional features to deal with those networks,
its function is to let you manage those four different objects: entities, entity
types, relationships and relations. This documentation aims to guide you through
the user interface. We split the items according to the user role who is
typically using them.

<!-- ## Searching, reading, exploring -->

<!-- ## Editing and relating -->

<!-- ## General features -->

## Administration

ConedaKOR lets you adjust most settings via its web interface. Most notably, you
can define the shape of your knowledge network, define permissions and change
some aspects of the web application.

### Managing entity types

If you follow `Administration -> Entity types` you are shown a list of entity
types. For each type, you can change the name, the allowed relations, add and
remove fields specific to that type.

When you click on the plus to create a new entity type or the pen for editing
and existing one, you will be at the entity type form:

* **Name**: the name of the entity type
* **Plural Name**: sometimes, the entity type needs to be displayed in its
  plural form
* **Description**: a description for this entity type
* **Tagging**: enables or disables tagging
* **Default label for datings**: this will be the default dating label on the
  form for editing entities of this type.
* **Label for the entity name**: for example, you might want to set this to
  `title` for artworks but to `name` for people
* **Label for distinct name**: the same but for the distinct name

Creating an entity type immediately allows you to create entities. You cannot
remove the Medium type since it is required. You can modify it to some extent,
though.

#### Fields

Click on the three thick bars of an entity type. That will bring you to the
field manager. Fields may be added, removed or modified. There are a few things
to set here:

* **Type**: the type of field you will create. This cannot be changed later.
* **Name**: the internal name of the field
* **Name on entity**: the label for this field when showing the entity page
* **Name on edit form**: the label on the entity form when editing
* **Name on search form**: the label on the search form when this entity type is
  selected
* **Visible on entity page**: should this field be displayed on the entity page
  at all? You might not want this when working with generators, see below.
* **Is identifier**: specifies if values for this field should be treated as
  identifiers allowing resolution
* **Regex**: the regular expression to use for validation

Some things to consider:

Currently, the **Type** is limited to

* `String`: allows simple text strings as input
* `ISBN`: like `String` but validates against ISBN-10 and ISBN-13
* `Regex` like `String` but validates against the given regular expression

The **Name** has to be unique per entity type. You can choose the same name for
two fields if they are defined for different entity kinds, but be aware that the
system assumes that those are semantically identical. For example, it might make
sense to have a field `viaf_id` on an entity type `Person` and the same one on
an entity type "Location", since entities of both types do in fact have VIAF
identifiers. Specifically, the setting **Is identifier** equally applies to all
fields with the same name.

**Name on edit form** and **Name on search form** default to the value of **Name 
on entity**

If you check **Is identifier**, you will be able to resolve entities by just
knowing its value of this fields. the mechanism can be triggered by navigating
to the url path `/resolve/<field name>/<field value>`. So staying with the VIAF
example from above, the url path `/resolve/viaf_id/24604287` would resolve to
the entity `Leonardo da Vinci` within your database. Changing this setting is an
complex task that ConedaKOR does in the background. This means that changes will
only have their effect after a delay. BTW, also `/resolve/24604287` will work if
there are no conflicts with other identifiers.

#### Generators

Generators compose small fragments of HTML based on the entity being on display.
The fragments are described as directive in AngularJS-flavored HTML.

* **Name**: the internal name of the generator (unique for entity type)
* **Generator directive**: the fragment to display on the entity page

Within the directive, you have access to the object `entity` so you can use its
data. Also, the full range of AngularJS-directives is available. For example:

    <span ng-if="entity.kind_id == 1">
      <span ng-bind="entity.uuid">
    </span>

would show the entity's uuid if its type is a medium. While

    <span ng-if="entity.dataset.gnd_id">
      <a href="http://d-nb.info/gnd/{{entity.dataset.gnd_id}}">
        German National Library
      </a>
    </span>

would access a field (defined on the entity type, see above) and display a link
to the German National Library the value is set.

<!-- ### Application settings -->
