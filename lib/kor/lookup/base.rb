# searh for items by term, prefix with "p:" to search for properties
# https://www.wikidata.org/wiki/Special:Search

# query:
#SELECT ?work ?title ?type ?sitelinks ?statements (COUNT(*) AS ?c)
SELECT ?work ?title ?type ?statements #(STR(?work) AS ?uri) (REPLACE(?uri, "http://www.wikidata.org/entity/Q", "") AS ?num) (xsd:integer(?num) AS ?id)
WHERE
{
  ?work wdt:P31/wdt:P279* wd:Q838948 .
  ?work wdt:P1476 ?title .
  OPTIONAL { ?work wdt:P31 [rdfs:label $type] }.
  #OPTIONAL {?work wikibase:sitelinks ?sitelinks} .
  OPTIONAL { ?work wikibase:statements ?statements} .
  FILTER(REGEX(STR(?title), "^.*mona lisa.*$", "i")) .
  FILTER(LANG(?type) = "en") .
  FILTER(LANG(?title) = "en") .
  #SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
}
#GROUP BY ?work ?title ?type ?sitelinks ?statements
#ORDER BY ASC(?id)
LIMIT 100
OFFSET 0

SELECT ?work ?title ?type ?sitelinks
WHERE
{
  ?work wdt:P31/wdt:P279* wd:Q838948 .
  ?work wdt:P1476 ?title .
  ?work wdt:P31 [rdfs:label $type] .
  ?work wikibase:sitelinks ?sitelinks .
  FILTER(REGEX(STR(?title), "^.*mona lisa.*$", "i")) .
  FILTER(LANG(?type) = "en") .
  FILTER(LANG(?title) = "en") .
  #SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
}
ORDER BY DESC(?sitelinks)
LIMIT 100

class Kor::Lookup::Base
  def name
    raise 'implement in subclass'
  end

  def url
    raise 'implement in subclass'
  end

  # should return a structure like
  # [{
  #   "id" => "12345",
  #   "title" => "12345",
  #   "url" => "https://example.com/records/12345"
  # }]
  def run(terms)
    return []
  end
end