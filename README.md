CurrencyTracker
===============

CurrencyTracker allows you to track your personal collection of world currencies, by tagging the countries 
that you've visited along your travels.
The application API responds with JSON after the identity of the requestor is authenticated. 
User authentication uses 'Devise' authentication with additional 'Tiddle' support which allows multiple tokens per user.
All the APIs are secured and expects 'X-USER-TOKEN' and 'X-USER-EMAIL' in the request header. 
The token can be retrieved once the user has been created by accessing 'http://localhost:3000/users/sign_in'.

Note: User creation is HTML view which provides a form to sign up.

Setup
-----
Start Application:
bundle install
rake db:migrate
'rails server'

Seed the database with currencies and countries by running:

```bash
rake db:seed
```

APIs
====
As explained above, there are two resources which can be accessed from the application - 'Countries' and 'Currencies'.
- Countries:
------------
1. GET 'http://localhost:3000/countries' will return list of all the countries in the application in the following format -
{
  "offset": 0, // Page number
  "total": 0, // Total number of records in response
  "order": null, // Sorted column
  "query": null, // Query generated based on input
  "rows": [ ], // Actual Data
  "elapsed": 0.006 // Response Time
}
This endpoint also supports pagination, sorting and searching which should be sent as parameters in the request like -
'http://localhost:3000/countries?per_page=10&page=1&sort=name asc&search=true&name=Country A'
-- per_page: Number of rows to return.
-- page: Number of the page to return.
-- sort: Column to be sorted on.
-- search: Boolean to ask for the search.
-- name/visited/code: Supported searchable columns with values to search.
Example Response:
{
  "offset": 1,
  "total": 1,
  "order": "name asc",
  "query": "name = \"Country A\"",
  "rows": [
    {
      "name": "Country A",
      "code": 3,
      "created_at": "2017-02-04 23:52:53 UTC",
      "updated_at": "2017-02-04 23:52:53 UTC",
      "visited": false
    }
  ],
  "elapsed": 0.001
}

2. GET 'http://localhost:3000/countries/3' [JSON] 
-- Returns country with code 3
Example Response:
{
  "name": "Country A",
  "code": 3,
  "created_at": "2017-02-04T23:52:53.000Z",
  "updated_at": "2017-02-04T23:52:53.000Z",
  "visited": false
}

3. GET 'http://localhost:3000/countries/3?visited' 
-- Returns visited status (boolean) for a country with code 3.
Example Response:
false

4. Charts Data
-- GET 'http://localhost:3000/countries/visited_over_time' returns countries visited over time which groups them in year buckets.
Example Response:
[
  {
    "year": "2017",
    "total_visits": 4,
    "code": null
  }
]
-- GET 'http://localhost:3000/countries/visited_vs_notvisited' returns count for visted and not-visited countries
Example Response:
{
  "visited": 0,
  "not_visited": 4
}

- Currencies:
-------------
1. GET 'http://localhost:3000/currencies' OR 
       'http://localhost:3000/currencies?per_page=10&page=1&sort=name asc&search=true&name=Currency A'
Example Response:
{
  "offset": 1,
  "total": 1,
  "order": "name asc",
  "query": "name = \"Currency A\"",
  "rows": [
    {
      "code": 3,
      "name": "Currency A",
      "created_at": "2017-02-04 23:54:15 UTC",
      "updated_at": "2017-02-04 23:54:15 UTC",
      "country_id": "3",
      "weight": "5.0",
      "collector_value": "25.0"
    }
  ],
  "elapsed": 0.002
}

2. GET 'http://localhost:3000/currencies/3'
Example Response:
{
  "code": 3,
  "name": "Currency A",
  "created_at": "2017-02-04T23:54:15.000Z",
  "updated_at": "2017-02-04T23:54:15.000Z",
  "country_id": "3",
  "weight": "5.0",
  "collector_value": "25.0"
}

3. GET 'http://localhost:3000/currencies/3?collected'
Example Response:
false

4. Charts Data
-- GET 'http://localhost:3000/currencies/collected_over_time'
Example Response:
[
  {
    "year": "2017",
    "total_collected": 4,
    "code": null
  }
]
-- GET 'http://localhost:3000/currencies/collected_vs_notcollected'
Example Response:
{
  "collected": 0,
  "not_collected": 4
}


Testing
-------

Run all test with:

```bash
bundle exec rspec
```
Note: Make sure database is seeded - 'rake db:seed RAILS_ENV=test'

Features
--------

* Track Visited Countries
* Track Collected Currencies
* Charts show you how far along you are!
