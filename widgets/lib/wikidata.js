wApp.wikidata = {
  setup: function(inputTag) {
    autocomplete({
      input: inputTag.input()[0],
      debounceWaitMs: 300,
      onSelect: function(item, input, event) {
        event.preventDefault();
        if (item.type == 'wikidata') {
          wApp.bus.trigger('wikidata-item-selected', item);
        } else {
          wApp.bus.trigger('existing-entity-selected', item);
        }
      },
      fetch: function(text, update) {
        var results = [];

        var w = wApp.wikidata.fetchWikidata(text, results);
        var e = wApp.wikidata.fetchExisting(text, results);

        Zepto.when(w, e).done(function() {
          update(results);
        });
      }
    })
  },
  fetchWikidata: function(text, results) {
    var promise = Zepto.ajax({
      url: 'https://www.wikidata.org/w/api.php',
      data: {
        action: 'wbsearchentities',
        search: text,
        format: 'json',
        language: wApp.config.data.values.wikidata_integration,
        uselang: wApp.config.data.values.wikidata_integration,
        type: 'item'
      },
      dataType: 'jsonp'
    });

    promise.done(function(data) {
      for (var i = 0; i < data.search.length; i++) {
        var item = data.search[i];
        item.group = wApp.wikidata.t('wikidata_items', {capitalize: true});
        item.type = 'wikidata';
        item.value = item.id;
        item.name = item.label
        if (item.description) {
          item.label += ' (' + item.description + ')';
        }
        results.push(item);
      }
    });

    return promise;
  },
  fetchExisting: function(text, results) {
    var promise = Zepto.ajax({
      url: '/entities',
      data: {terms: '*' + text + '*'}
    });

    promise.done(function(data) {
      for (var i = 0; i < data.records.length; i++) {
        var item = data.records[i];
        item.group = wApp.wikidata.t('existing_entities', {capitalize: true});
        item.label = item.display_name;
        item.type = 'existing';
        results.push(item);
      }
    });

    return promise;
  },
  t: function(input, options) {
    options = options || {};
    return wApp.i18n.translate(wApp.session.current.locale, input, options);
  },
};
