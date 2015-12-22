#!/bin/bash

curl -X POST http://localhost:9200/wikidata/items/_search -d"
  {
    \"query\": {
      \"query_string\": {\"query\": \"univ*\"},
      \"script_score\": {
        \"script\": \"_id\"
      }
    }
  }
"