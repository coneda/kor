# ConedaKOR documentation | Users

## Target audience for the guidelines

These guidelines are aimed at scholars and institutions who wish to collect, manage and store their data using the ConedaKOR software. ConedaKOR allows for granular rights management differentiating among the administration, the input and editing of further data records, and finally the search in the database. These roles are termed *Administrator*, *Editor*, and *User*. The guidelines are divided into four sections that address the requirements and duties of these three roles. A separate [document](ops.md) is aimed at system administrators.

| Role | Section in the guidelines |
| --- |--- |
| administrator, editor, user | [What is the idea behind ConedaKOR?](#what-is-the-idea-behind-conedakor-and-what-are-its-particular-strengths) |
| administrator, editor, user | [Initial orientation: GUI and basic functions](#initial-orientation-gui-and-basic-functions) |
| administrator | [Setting up the database and performing basic configurations](#setting-up-the-database-and-performing-basic-configurations) |
| administrator | [Creating the structure of the data](#creating-the-structure-of-the-data) |
| editor | [Entering data and organizing into collections](#entering-data-and-organizing-into-collections) |
| user | [Using the database for research](#using-the-database-for-research) |

These videos also offer an initial overview of the structure and functions of ConedaKOR:

* [Installation of ConedaKOR with Docker](https://av.tib.eu/media/60132)
* [Creating entity types, entities, and relations in ConedaKOR](https://av.tib.eu/media/60133)
* [Creating fields and generators in ConedaKOR](https://av.tib.eu/media/60134)

When first trying out ConedaKOR, it is advisable to operate it in a Docker container and only for a single account. This is explained in the video [Installation of ConedaKOR with Docker](https://av.tib.eu/media/60132). However, installation is necessary for regular operation with multiple user accounts. This is explained in the [Documentation for admins](ops.md) and requires a certain basic knowledge of server administration and the operation of web servers.

## What is the idea behind ConedaKOR, and what are its particular strengths?

ConedaKOR is a software for archiving, managing, and searching image data and metadata on a common, web-based interface. On a conceptual level, ConedaKOR is implemented as a graph database system, which means that the information entered in the database is managed in the form of entities and relations among those entities. Therefore, the entities (nodes) and the relations (edges) are reflected in a common graph. This structure is not only very flexible but also supports associative searches according to the relationships content-wise among the data entries. Among other uses, this is of particular interest in cases where users wish to access new knowledge via the database.

The structure in nodes and edges also allows, for example, a simple distinction between an object as an entity and the different representations of this object as further entities. Likewise, a concept (e.g. a play, a type, a motif) and its realizations (performances of a play, specimen copies of a given type, applications of a motif in a story, an image) can be created and managed individually, while their affiliation from a content standpoint is presented through their relations. By adding further entities, a network is created that not only provides information on the individual entity but also enables interactive navigation through the database. The ConedaKOR database is thus based on a system of virtual entities that are connected to one another by relations.

In the ConedaKOR graph model, these entities and relations are typed, i.e. they are assigned to superordinate content types (e.g. one entity type each for "people," "events," and "literature"). Each of these types in turn contains a specific set of information. As a result, the possible entities and their relations in the graph are controlled in such a way that no illogical, erroneous information complicates later use. Thanks to an unlimited number of free attributes, the entities can be enriched with additional information. It is also possible to refer to controlled vocabularies, authority files, or Wikidata (see video: ["Creating fields and generators in ConedaKOR"](https://av.tib.eu/media/60134)).

### Integration of images and data files as a separate entity "medium"

One of ConedaKOR's strengths lies in the management of image and other data files, which are created and managed as their own entity types (mediums). Various media can be assigned to an object (an entity), each with its own metadata regarding its authorship, dating, and so forth. In addition to a preview of the images optimized for the web, higher resolutions can also be made available for download when searching. Thanks to the
[segmentation of the database into "domains"](#Segmenting-the-database-into-domains) (explained below in greater detail), media protected by copyright or other rights can also be systematically shielded without having to be removed from the database.

### Schemas and Wikidata lookup

Another specific quality of ConedaKOR is that it supports the use of authority files, the inclusion of schemas like [CIDOC CRM](https://www.cidoc-crm.org/), and the integration of [Wikidata](https://www.wikidata.org/) (Wikidata lookup). Offering the option of Wikidata integration, the lookup makes it possible to use existing data sets in Wikidata when creating entities (people, places, etc.) in ConedaKOR. When creating a new entity in ConedaKOR, search results from Wikidata are displayed; the matching entry can be selected with a mouse click. The corresponding Wikidata content will then populate the name of entity field and the comments field. If the entity type has a field for a Wikidata ID, this will also be entered automatically.

### Scalability of the database for different contexts

ConedaKOR initially developed out of a specific use case, namely, the creation of an image database for the Institute of Art History at the Goethe-Universität Frankfurt am Main. Starting from this institute in Frankfurt, the software has come to be used by other art-historical institutes as well as by adjacent disciplines. However, ConedaKOR is not a database solution exclusively for art history but rather a software that can be used to record and manage data regardless of content or subject. ConedaKOR is particularly adept at supporting the subdivision of the database contents as well as the subdivision of user accounts in user groups. Among other functions, this allows for the depiction of the entire proceedings of a seminar in a stable format.

## Initial orientation: GUI and basic functions

### Graphical user interface (GUI)

The GUI consists of the navigation menu along the left edge of the screen and the selected function, which is displayed in the central pane of the screen. At the top right is the login and the option to modify the data of one's user account. The composition of the functions on the left-hand side of the screen depends on the respective authorization level (administrator, editor, or user). They all have functions for guiding the search, a clipboard, and information about the software and terms of use.

### General symbols for operation

ConedaKOR uses a set of icons that recurrently call specific functions within a given process.

The following are for all editing and search operations:

* ![plus](icons/plus.svg): adds search or input options or relations
* ![minus](icons/minus.svg): resets and removes options; removes objects
* ![trash](icons/trash.svg): in principle, irrevocably deletes the relevant entry, object, or context
* ![pen](icons/pen.svg): calls up a form in which objects can be created or modified
* ![edit](icons/edit.svg): initiates a editing process
* ![bla](icons/bla.svg): temporarily saves on the clipboard

Help and interaction with the database managers:

* ![question_mark](icons/question_mark.svg): calls up help texts that are then displayed below the respective field
* ![exclamation](icons/exclamation.svg): initiates an email to the database manager

To use data outside of the database:

* download: creates a zip file and initiates its download
* code: outputs the respective entities as JSON files, which can then be directly copied

Successful edits are confirmed by a grey box at the top of the screen, which describes the completed operation. Any errors (including information in the wrong format) are indicated by a corresponding red box with an error description.

### Breakdown into domains, collections, and directories

With ConedaKOR, the database content can be structured according to access rights and content-dependant aspects. *Domains* segment the data within a database according to access rights. For example, media that cannot be viewed by users for copyright reasons can still be kept and maintained within the same database. Domains are therefore subgroups in the database that are justified from an administrative standpoint.

*Collections* group together entities according to content-related aspects and are available to administrators in the form of global collections as well as to individual users as personal collections. These could be designated object groups or a seminar topic, for example. However, the entities are always locatable independent of the collection, and they can be part of more than one collection. If necessary, a collection can also be made publicly available and, with corresponding approval, can also be viewed by users without a user account.

With *directories*, global collections can be grouped further, for instance, to design subject areas or to serve the logistical structure of an organization.

### Looking at a data entry: The entity page

A data entry consists of the entities and their relations. When a user views an entity, the relations are also displayed, along with the various descriptive entries. If the entity is linked to a medium, this is visible as a thumbnail. In addition, depending on the database settings, the *reference data* will also be made accessible to the users.

The *reference data* contain an automatically generated Universally Unique Identifier (UUID) for the entity in question. The information in the *domains* shows to which segment of the database the entity belongs, and "degree" indicates the number of linked entities. An entity linked to a medium has "Degree: 1", while an isolated entity has the value "0". Information on the authorship of the entity and on its editing can, on the one hand, support quality control and, on the other hand, be seen as a micro-publication.

As soon as an entity has been assigned to a *global collection* (i.e. a thematically limited collection), the path appears as further information in the reference data.

## Setting up the database and performing basic configurations

The overall behaviour of ConedaKOR and all basic settings for the database can only be defined by administrators. For this purpose, extensive functions can be found on the left-hand side of the screen under the heading *Admin / Administration*; these are organized into four categories. They can be used to a) adjust the view and descriptive texts for the project in question; b) separate areas of the database; c) manage users in groups; and d) manage user accounts individually.

### Customization of the database via *settings*

#### Display and Branding

It is in the *settings* pane that the database receives its specific information texts, its title, and instructions for use. All texts entered in the first six fields are made publicly available online and should therefore be complete. The *maintainer* *organization* field records the name of the institution or person responsible for the specific database installation and its contents. The *maintainer email address* is used by the system as the return address for all information (messages about a download, messages about status changes, etc.) and also serves as the destination address for the navigation point *report a problem*. A checkbox can also be used to ensure that media contained in the database (usually images) are displayed on the welcome page.

This is followed by a number of fields that define the display and labelling of certain basic properties of the respective database. Many of these are self-explanatory. Some are briefly explained here:

* *Path to a custom css file*: This allows you to use your own user interface display settings, such as fonts and background colours. The full URL to a CSS file must be entered here.
* *Label for the "new media" page*: This will change the naming of the third menu item on the left of the screen from the default "new media" to "new entities."
* *Label for the button toggling the local login (leave empty to always show form)*: This results in a SSO (single-sign-on) button being rendered on the login form. See the [operations guide](ops.md#external-authentication) for more details.
* *Label for the entity name on the search page*: This determines how the entities are displayed for users in the list of search results.
* *Primary relations* and *secondary relations* together form the caption for media when in gallery view (e.g. under "new entities"). The entities linked via these relations are displayed under the medium.

#### KOR settings

Various technical functions for using the database are controlled in this area, such as download size and the inclusion of IIIF manifests as well as their display in a viewer. Again, the fields are largely self-explanatory, and only a few will be briefly commented on below. It is also advisable to accept the supplied basic-setting values as long as there are no specific empirical values that would suggest a change.

* *Default language*: The language selected here (German or English) will be used for unregistered visitors as well as new users.
* *Maximum number of results per request*: This sets a cap on the results returned by the JSON:API.
* *Publishments lifetime \[days\]*: Collections can be made available to the public without an account. This release is subject to a time limit that is specified here.
* *Default user groups for new users*: New accounts are automatically assigned to these user groups. The corresponding groups must first be created.

The following field and the subsequent checkbox enable the integration of [Wikidata lookups](https://av.tib.eu/media/60134):

* *Use the Wikidata integration*: In order to use the integration, it is necessary to select the Wikidata language version in which the autocomplete should be queried. The content is also preferably inherited in this language.
* Checkbox *Create missing relations?*: With this option, additional new relations are created when entities are fetched from Wikidata. Otherwise, links are only created if a corresponding relation already exists.

Two additional fields enable the integration of IIIF technologies into ConedaKOR. The Mirador viewer is included so images can be viewed and compared above. The following settings are used to customize the display and behaviour of the viewer.

* *Override the page template for the mirador integration (absolute path)*: Use a custom page with an integrated Mirador viewer.
* *Override the manifest template for the mirador integration (absolute path)*: Use your own template when generating the IIIF manifest.

#### Customization of help functions

In this area, one can customize the various help texts, which contribute significantly to problem-free use of the database. Users can access these help texts via the *question mark* above the right corner of a field; the texts are then displayed under the relevant field.

#### Links to the software project under "More"

With the functions in this section, it is possible to reference one's own *fork* of the software. If no further development of the open source software is carried out, the values already supplied can be adopted here.

### Segmenting the database into domains

As briefly described in the introduction, the construction of domains enables the establishment of sub-areas within the database. They are only accessible to certain user groups, and depending on the settings their entities can be neither searchable nor visible outside the domain, or they can be searchable but not downloadable. A common example is the inclusion of copyrighted media that may only be accessed by a narrow circle of people.

The creation of a new domain is initiated via the plus icon, which opens a form. There, the authorizations for various activities related to user groups must be allocated, after assigning a domain name.

### Structuring the contents of the databases with global collections and directories

The *global collections* and *directories*, which are created via the menu item *global collections*, enable a further, reversible structuring of the database content. This allows for the formation of semantic links (e.g. overarching topics) that cannot be made manifest directly in the individual entities and their relation or that arise from logistical connections (e.g. collections of material for different working groups).

### Controlling access via user groups

#### Overview

Users are managed individually in ConedaKOR and are assigned to user groups. The authorizations of the individual user groups are assigned per domain. Correspondingly, members of group X in domain A can have different authorizations than in domain B. User groups are intended to represent functions. Accordingly, users and editors can be assigned to different groups, and research-team configurations with varying responsibilities can be illustrated. Each user account can belong to more than one group, which, together with the domain-specific permissions for each group, allows different arrangements to be actualized in the individual administrative segments of the database.

#### Creating user groups

To create user groups, one calls up a form, on which only a name and an explanatory description are entered. The permissions of the group result from the settings per domain.

### User accounts: Managing users individually

User administration allows you to manage the users who can log in to the installation.

User accounts are always password protected.

The administrator resets a password using the key icon. With *unlock*, the user's login attempts are reset. An administrator can also use the *active* checkbox to activate or temporarily deactivate a user account.

In addition to belonging to user groups, the individual user accounts can be granted very far-reaching authorizations across the entire database. These rights correspond to those of an administrator and should only be assigned to a narrowly defined group of people.

After saving a newly created user account for the first time, an API key is automatically generated.

## Creating the structure of the data

### Structural elements

As a graph database, ConedaKOR manages the information as nodes (entities) and edges (relations). The entities can be assigned to different entity types; for each of these types, a specific set of properties is defined. The use of the individual relationships can also be restricted to specific entity types. In this way, rules are established to govern data input, making the subsequent retrieval of data easier.

Despite these simple basic elements, complex relationships can also be modelled in the database, as demonstrated by the diagram of connections for the ConedaKOR installation of the Institute of Art History at Goethe-Universität Frankfurt am Main ([Link to the examples](https://github.com/coneda/kor_leitfaden_ffm/wiki#verknüpfungsschemata)).

Not all entity types have to be assigned concrete entities; they can also be abstract concepts that enable the creation of hierarchies of entity types.

### Entity and entity types

#### Definition and explanation

In ConedaKOR, the entities correspond to the virtual manifestations of those objects and categories of scholarly work that can also in reality be distinguished from one another (e.g. works, illustrations, authors, secondary literature).

Entities are the carriers of information that are displayed in two ways:

1. as properties of the individual entity (one can also speak of metadata here)
1. through links to other entities

The entity is typed in ConedaKOR with the *entity type*. The relationship between entity type and entity thus corresponds to that between a style sheet and an actual text.

#### Creating and changing an entity type

##### Basic procedure

Only authorized users can create, change, and delete entity types. Functions for creating and managing entity types can be found on the left edge of the screen under the heading *create*. In the basic settings, ConedaKOR already offers the entity type *medium*, which supports the management of additional files (often images). This type cannot be deleted but can be renamed. A window opens in the central pane of the screen that lists all the entity types created for the database (*medium* is the only type to be found here at the outset).

##### Mandatory fields and their naming

Each entity type must be given an individual designation (*name*), which is always entered in the plural (*plural name*). This designation is visible to all users and enables them to find their way around in the database. The optional *description*, on the other hand, is only visible to the administrator and is intended to support their work.

##### Optional fields

ConedaKOR offers additional fields that allow the entity type to be customized to the respective content of the database.

* *tagging*: Use *activate tagging for this entity type* to determine whether the entity type can be tagged by users who otherwise have no editing rights. In addition, one can set the *default label for datings* and the field labels for the name and the unique name of the entity.
* *Schema* and *schema url*: This can be used for categorization if, for example, synonymous types from different schemas come into play. If one or more "root types" are specified, a hierarchy of entity types can be created. This structure is then outputted via the interfaces. Entity types can be defined as *abstract* and thus serve to hierarchically organize entity types. Accordingly, no entities can be created for *abstract* entity types.

##### Establishing custom fields

Any number of fields can be created for a given entity type, which enables further customization to specific needs. All of these fields are visible to the editors when creating and modifying the corresponding entity and, if desired, can also be displayed to users. A designated form opens that allows for detailed configuration of the field, whether while creating or editing it.

###### Field type

The *type* must be specified for each field, and this selection restricts which input values are permitted down the line.

ConedaKOR offers the following types:

* *string*: Inputting a text or a number that the system does not
* treat as a numerical value. The text cannot contain breaks, italics, and so forth.
* *ISBN*: This field type is intended for inputting ISBN numbers (ISBN-10 or ISBN-13).
* *multi-line text*: It is possible to input a text of multiple lines.
* *select*: Allows for the specification of a list of values, which can be selected from a dropdown while entering data.
* *regex*: Allows for the entry of a [regular expression](https://rubular.com/) in a separate field, with which to validate the input.

###### Field labelling 

ConedaKOR offers detailed options for assigning the same field customized names for the machine and the different user groups, respectively. This means that project-internal terms can be used to label the field when inputting the data, while a different term is displayed for the users.

* *Name*: Each newly created field must first be given a label that is machine-readable. This must consist of lower-case letters, and any string of several words must be connected with an underscore.
* *Label*: The label that is to be displayed later on the entity page is defined here.
* *Label on edit form*: Allows for the specification of an additional
* label that the editors will see when inputting and editing in the field.
* *Label on search form*: Controls the label that is retrieved via the search form.

Only those fields for which a value has been entered will be displayed on the
entity page.

###### Help text

The help text can be used to provide editors and users with further information about the content and meaning of the field values in relation to all entities of a given entity type.

###### Behaviour of the field

The display of the fields and their behaviour are controlled with three checkboxes:

* *is mandatory*: When creating an entity of this type, the input process cannot be completed without specifying a value.
* *visible on entity page*: Only if this box is checked will the field and the value entered be displayed on the entity page.
* *identifier*: entity resolution is possible using the field value "/resolve/". For example, an entity "Leonardo" of the type "Person" with a field "gnd_id" that is typed as an *identifier* and contains the value "118640445" would be found via the URL path `/resolve/gnd_id/118640445`.

#### Facilitating the integration Wikidata IDs using the field "wikidata_id"

Using the general procedure for creating fields, one can facilitate the semi-automatic transfer of the Wikidata ID to an entity. This procedure is described in the above introduction under [Wikidata lookup](#Schemata-und-Wikidata-LookUp).

The field name must read "wikidata_id", and the Wikidata integration must be activated in the general settings by selecting a language for the interaction between ConedaKOR and Wikidata, see the general settings in the *administration* area. The field type is to be set as a *string*, since Wikidata entity numbers always begin with the prefix "Q".

#### Defining generators to enable linking

Generators are a way of converting entity values into links and other HTML snippets. This makes it possible, for instance, to display the value "76353174" in a field labelled "viaf_id" as a link to the entry [Viaf.org](https://viaf.org/), i.e. as <https://viaf.org/viaf/76353174>.

A generator requires a machine-readable label in the *name* field, which must
consist of lowercase letters and underscores. In addition, a *generator
directive* must be inserted. An HTML template is given here, which can be
assigned placeholders. The template is to be created in [ejs](https://ejs.co/)
format.

To stay with the example above:

    <% if (entity.dataset.wikidata_id) { %>
      <a href="https://viaf.org/viaf/<%= entity.dataset.wikidata_id %>">
        » Wikidata
      </a>
    <% } %>

With `<%= entity.dataset.<Feldname> %>` a specific field value can be used. The condition `<% if (entity.dataset.<Feldname>) { %>` first checks whether the field value has been set and otherwise hides the `<a\>` element.

### Relations

#### Definition and explanation

As described below under [Structural elements](#Structural-elements), relations are the second element with which to structure information in ConedaKOR. Again, ConedaKOR distinguishes between the type (the relation) and the concrete application between two entities (the relationship). The relations are also typed in ConedaKOR. By creating a relation, one can establish its designation and adjust which entity types can be connected to one another. This results in an even application of links among the entities and allows for problem-free searching in the database down the line.

Relationships are always two-way, which means that a relationship between entity A and B implies a inverted relationship between B to A. This requires linguistic adjustments when creating the relation so that it remains intelligible (e.g. "is part of" could correspond to "consists of"). Therefore, when viewing one or the other of two linked entities, the link between them will not have an identical label; rather, the label is determined by the perspective of the currently viewed entity.

#### Creating a relation and determining its properties

Relations can only be created, modified, or deleted by administrators. The *relations* function can be found under *create* on the left-hand side of the screen. From there, existing relations can be edited and new ones created.

Thanks to a number of mandatory and optional fields, the properties of relations can be customized to specific needs.

##### Mandatory fields

* *Name*: A human-readable designation that expresses the relation's semantic.
* *Inversion*: The inverse meaning of the *name*
* *Permitted type (from)*: Designates the type of entities allowed to be connected with this relation (origin)
* *Permitted type (to)*: Designates the type of entities allowed to be connected with this relation (target)

##### Optional fields

ConedaKOR supports the use of standards and Wikidata with the following features:

* *Schema*: A unique identifier for the relation (when fetching data from Wikidata, this value is matched to allow for proper correspondence of properties)
* *ID* and *reverse_ID*: One initiates the fetching of information from Wikidata by entering the respective Wikidata property and its inversion (e.g. [P170](https://www.wikidata.org/wiki/Property:P170) for "creator" and "created by").

The relations can also be organized into hierarchies. This is done using:

* *parent relation*: Relations of the same name from different schemas can be used here; for example, the entry  "https://cidoc-crm.org/html/cidoc_crm_v7.1.2.html#P14" would apply the property "P14 carried out by (performed)" from the CIDOC CRM to the relation in the database. The hierarchy established here is also relevant when querying the data via the interfaces. It should be noted that the combinations of permitted entity types, which are already restricted by the root type, cannot be expanded by the relation. Therefore, the hierarchy of the relations interacts with that of the entity types.
* *abstract*: This relation enables the insertion of levels in the hierarchy, which themselves cannot be instantiated as concrete realationships between entities. They are only used for structuring complex data models.

## Entering data and organizing into collections

### Overview

Data entry requires editor rights for at least one domain.

In ConedaKOR, data is broken down into entities and their relationships (see also
[What is the idea behind ConedaKOR?](#What-is-the-idea-behind-ConedaKOR-and-what-are-its-particular-strengths)). Entity types and predefined relationships help to correctly create the individual entities and links. Because ConedaKOR was initially developed for the purpose of building an image database, there is an extended functionality for uploading images, which are then always assigned to the entity type "medium".

In order to structure the entities in the database according to their content, they can be grouped into "global collections." Global collections can be further structured using directories. Only users with adequate rights can
[create global collections and place them in a directory](#Structuring-the-contents-of-the-databases-with-global-collections-and-directories).

#### Entity creation

The creation of an entity is initiated via the *create entity* function, which can be found on the left edge of the screen. The desired entity type is selected from the dropdown menu. A form then opens in the central pane of the screen; this contains all the fields for entering values for the respective entity type. Only if all mandatory fields are completed will the entity be saved.

If the entry is interrupted after all mandatory fields have been filled in, the entity can still be saved for editing at a later time. As soon as this is done, the entity receives an entity number relevant to the database. It is visible in the browser's address field (e.g. `<kor-url>/#/entities/1234`). By entering a number in the address field, one can access the corresponding entity without having to make use of the search mask.

Each newly created entity also receives a UUID (Universally Unique Identifier). The UUID is an automatically generated character sequence that unambiguously and persistently identifies the entity worldwide. Based on the UUID, the entity can always be found regardless of changes to the Title/Name fields or to the entity number (in the case of media). The UUID is listed on the entity page under the reference data and can be queried using the search.

How the fields are to be filled depends on the configuration of the individual database. Ideally, the input is supported by help texts created by the administrators. In addition, it is advisable to draft handouts for the editors.

#### Creating relations

As soon as an entity has been completely created and saved, it can be linked and thereby receive all additional information. Images are only included when an entity is linked to another of the "medium" type.

To establish the relation, open the entity view and call up a form via the plus icon under the heading *relations*:

* *relation*: Here, one selects to which relationship the new, concrete connection should belong.
* *entity*: The entity to which the link should lead must be specified here. The search for the entity in question is supported by a) a keyword search; b) a review of the most recently viewed entities; and c) a review of the most recently created entities.
* *additional properties Add*: Further details on the connection between the two entities can be specified here.
* *dating information Add*: Provides more accurate dating information and is of particular interest for databases on historical and archaeological subjects.

#### Editing of entities

Any existing entity can be edited at any time. The input form is called up via the pen icon on the view page for the entity.

ConedaKOR also simplifies data entry by offering, on the left edge of the screen, functions for locating the most recently input entities as well as faulty entities.

These are:

* *new entities*: Calls up a listing of all entities, in descending order by editing date/time.
* *isolated entities*: Shows entities that have no links.
* *invalid entities*: Collects entities that were created through automated import processes and that require manual post-processing.

### Uploading image files

Before image and text files are available for linking as entities of the entity type "medium," they must be made available to ConedaKOR. This is done by uploading the files. If necessary, the media are assigned to a personal collection, thus simplifying further handling. To upload the images, the following steps must be carried out, thus triggering certain procedures:

1. *upload*: Opens the function in the central pane of the screen
1. Storage of the uploaded images in a collection. ConedaKOR automatically saves to a personal collection any image files uploaded by a user within a given day unless an existing collection is selected prior to uploading or a separate one is created with a custom name.
1. *add files*: In the file browser, the files are selected and registered for upload on a list that appears in the central pane of the screen. The list can be edited by deleting individual entries or by removing the entire list using the *empty list* function.
1. *upload*: All files entered on the list are uploaded and thus become "media." They can then be found under the "new entries" menu item on the left-hand side of the screen or in the previously selected *personal collection*.

The media are now available within the database for further linking and assignment to other collections.

### Clipboard

The clipboard allows certain functions to be applied to multiple entities. For example, several uploaded media can be placed on the clipboard in order either to be selected one after the other for linking to other entities or to be moved all at once to one of the global collections.

Via the *clipboard* function on the left edge of the screen, one can access two dropdown menus:

* With one click via the *selection* menu, one can select all entities of a certain type.
* The operation to be performed on the selected entities is defined in the *active* menu field.

In addition, the clipboard offers the possibility to merge, into a single entity, entities that have accidentally been created multiple times for the same object. This operation is called "merge."

### Media and entities entered in error or multiple times 

Entities enter in error can be retrieved and deleted individually. Media and entities that were accidentally entered twice can be merged in a targeted manner. To do this, place both on the clipboard, select them, and combine using the merge command.

## Using the database for research

ConedaKOR was developed to support users of differing expertise in searching for entries, and especially for images. Accordingly, it is possible to perform both the more classic search -- entering exact titles or keywords into a search field -- as well as to search using a combination of values in various fields. In addition, navigating through the links opens up a search that is associative and serendipitous.

### Searching

On the one hand, the search form offers a one-field search, whereby the system searches for matches between the search terms in the name of an entity and in the names of the linked entities. Any number of terms can be combined in the search field. The exact syntax for the search can be viewed using the help button in the search field.

The results can be further filtered according to *entity types*, *tags*, dates, and *further properties*.

Beyond that, the entities returned by a search can be limited to those that are themselves linked to entities specified in the *Search in related entities* field.

If an entity type is selected for which additional fields have been defined, corresponding search fields will also be offered for these.

#### Navigating through the relations

The ConedaKOR interface is designed so that users can search associatively and be guided by the relation between the entities. This is appealing particularly for users who wish to familiarize themselves with the contents of the database but who only have limited specialist knowledge of those contents.

Each entity page offers an overview of all existing relations to other entities and opens them with a click. This search primarily emphasizes connections between entities that can only be partially mapped via the titles.

### Ordering and saving the results

#### Search results

The search results are listed in the right pane. If there are more than ten search results, arrows at the top right allow you to scroll through the results, arranged by page. Entities from the search results can be added to the clipboard via the checkbox, and from there they can be further processed at a later time.

The "media" themselves are not independent but rather are listed in the search results via entities linked to them. In cases where previews of image material can be seen in a search result, the corresponding illustrations serve as a direct link to the "medium," i.e. the image file itself; this is independent of the entity type under which the image is displayed in the search results.

#### Collecting on the clipboard and downloading as a personal collection

The *clipboard* allows one to collect any number of entities in the course of research. This is carried out either using the copy_doc icon in the list of search results or on the page for the entity that is to be entered on the clipboard. The clipboard serves as a temporary storage location in which to collect the results of a session's various searches. It can then be saved as a personal collection.

The media linked to the entities that are grouped in a given collection can be downloaded as a zip file using a corresponding icon in the collection view. The file is zipped together with a text file containing the UUID for the medium (see also
[Looking at a data entry: The entity page](#Looking-at-a-data-entry-The-entity-page)).
