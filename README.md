# ConedaKOR #

ConedaKOR allows you to store arbitrary documents and interconnect them with
relationships. You can build huge semantic networks for an unlimited amount of
domains.

To learn more and for installation instructions, please visit our
[our website (German)](http://coneda.net/pages/download)

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
* Easy extension of the schema for every kind of entity
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


## Main Navigation ##

This should give a rough overview on what the navigation items are good for. The
menu doesn't show every item to every user. The full version is only visible for
fully authorized account (e.g. the default admin account).

* **Edit profile:** Within this menu item it is possible to change the username,
  email adress, password and to preset the front page, which appears after the
  users login. Furthermore a default collection can be chosen in which uploaded 
  media will be placed; while working on new entities and media it is possible
  at any time to change the collection the user wants to expand.
* **Clipboard:** The Clipboard serves as a temporary storage during a research,
  the user can collect different media by using the menu item "" (copy to 
  database). The medium will be saved on the Clipboard and can be added 
  subsequently to a private or global group. The collected media will be
  deleted from the clipboard after the log-out.
* **New Entries:** Assorted samples of recently added media are listed here.
* **Simple Search:** The menu item "simple search" navigates the user to a quick
  search tool. 
* **Expert Search:** The "expert search" provides more criteria, e.g. name,
  date, further properties and tags, to refine the resulsts. In addition to the 
  given research criteria the user can add "additional criteria", such as 
  author, location, institution etc.
* **Groups:** Within a Collection "Global Groups" are compiled by admins only 
  and available for the other users, whereas "own groups" are only accessible 
  by their author. A private user can publish his/her group to give other users
  access to the respecting group, a shared group can also be edited by the other
  users.
* **Create Entity:** Different entities such as exhibition, embedded medium, 
  institution, literature, medium, location, person, collective of persons, text
  and works can be created here. The menu item "multiple upload" allows to 
  upload more than one medium.
* **New Entity:** New types of entities can be set up here and are later on
  provided in the menu item "create entity".
* **Administration:**
  * **General:** Genereal settings can be changed here: The site operator’s name
    and mail adress, server port/adress and protocol, email server and port; 
    settings concerning different applications, such as relations between media,
    maximum file size for upload, primary and secondary relations.
  * **Relations:** The admin can declare any number of relations betweens the
    different types of entities, i.e. how media, persons, locations etc. can be
    connected while expanding the database.
  * **Entity Types:** Different types of entities can be created and are alter
    on available while uploading new media.
  * **Collections:** The admin has got the oppurtunity to set up different
    collections to limit access and editing to different groups of users.
  * **User Groups:** Different user groups and their rights to use the database
    can be set up und edited here.
  * **User Administration:** The users and their accounts can be managed with
    the settled user groups , the duration of user accounts can be extendet and
    right to edit new media can be given to them.
* **Statistics:** This menu item comprises general statistics, for example how
  many media has been uploaded.
* **Error Report:** Reports of errors are listed here.
* **Terms of Use:** Terms of use can be edited here.
* **Imprint:** The imprint can be edited here.
* **Coneda.net:** Embedded link to Coneda UG’s homepage.

# Documentation

These instructions are intended for system operators who wish to deploy the 
software for their users.

## Import and export

Please refer to the command line tool.

## Command line tool

The kor command provides access to functionality which is not easily provided 
from a web page. For example, the excel export potentially generates many large
files which are impractical to download. You may call the command like
this

    bundle exec bin/kor --help

from within the ConedaKOR installation directory to obtain a detailed
description of all the tasks and options.
