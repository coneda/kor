# Kor JSON REST API Documentation

The Kor JSON REST API is split up into several sections dealing with a specific
data type (e.g. entities or relationships) each. Each section then has several
endpoints handling a specific aspect (e.g. showing or deleting) of that data
type.


## General

All endpoints follow these general rules

* **HTTP verbs** indicate the type of action (e.g. GET requests will read, POST
  requests will make modifications)
* parameters are expected
  * part of the url path when indicated (e.g. "/entities/:id")
  * to be **query string parameters** for GET requests
  * to be **json encoded in the HTTP body for POST, PUT and PATCH requests
* the **request body** (if applicable) is expected to be a **JSON document**
* requests must specify the **HTTP header** `Accept: application/json`
* the **response body** is **JSON encoded**
* the **HTTP response code** should indicate success, redirection or problems
* when errors occur, more information might be found in the response body (e.g.
  `{message: "Couldn't find User with 'id'=100"}`)
* TODO: sorting

In this documentation we show JSON content as parsed JavaScript objects, e.g.
`{some: 'value'}` instead of `{"some": "value"}`.

## Authentication

Authentication is not required in which case returned results reflect the 'guest'
user's access level. API requests may include a authentication key in order to
receive content with elevated permissions. The key can be passed in one of the
following ways:

* as a HTTP param `api_key` given as query string parameter or as JSON encoded
  body parameter
* as a HTTP request header `HTTP_API_KEY`
* as a HTTP request header `API_KEY`
* as a HTTP request header `api_key`

The api key for each user can be retrieved through the profile page or (as a
user admin) through the users edit page in the user manager.

## Parameters

These parameters are available for endpoints that return **several paginated
results**:

* `page` [integer] The result page for paginated results
* `per_page` [integer] The amount of results per page for paginated
  results. The value is capped by the setting "maxium number of results per
  request".
* `include` [strings] A list of information aspects to include, this parameter
  is described in detail for the endpoint to retrieve a single record but
  usually works for the listings as well.

Some updating endpoints allow for a parameter `lock_version`. If it is used,
the updated resource's lock_version is compared to the given value and the
update is denied if the values don't match. This can be used to prevent
accidental overwrites when competing updates occurr on the same resource.

For parameters specific to the respective endpoint, see the
[endpoint reference](#endpoint-reference) below.

The following parameter types are currently in use. When the type is given in
plural, multiple values can be specified, separated by comma, for example,
type "integer(s)" would allow values like "1", "223" or "44,55,66".

* integer
* string
* kor date format - please refer to [our test suite](https://github.com/coneda/kor/blob/master/spec/lib/kor/dating/parser_spec.rb#L203) for currently acceptable values 
* content type - any valid content type, such as "application/json" or
  "image/jpeg"
* true type - the parameter only allows the value "true", every other value (or
  omitting it) designates "false"


## Collection responses

Whenever a endpoint returns **several paginated results**, the result will be
wrapped into an object with the form

~~~javascript
{
  results: [...], /* the actual results */
  total: 123, /* the total amount of results ignoring pagination */
  page: 1, /* the current page of results being returned */
  per_page: 10 /* the amount of results returned per page */
}
~~~

## Endpoint reference

This is a detailed list of all endpoints the JSON API exposes.
