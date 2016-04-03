var ComponentSearch = new Object();

ComponentSearch.results = [];

ComponentSearch.setup = function() {
  $('#search_terms').
    keypress(this.autocomplete_enter_key).
    autocomplete({
      source: this.autocomplete_source,
      select: this.autocomplete_select,
      minLength: 3
    }).
    data('uiAutocomplete').
    _renderItem = function( ul, item ) {
      return $( "<li></li>" ).
        data( "item.autocomplete", item ).
        append( "<a>" + item.label + "</a>" ).
        appendTo( ul );
    };
  
  $('body').on('click', '.query_item a', function(event){
    $(this).parents('.query_item').remove();
    return ComponentSearch.form_submit();
  });
  
  $('form select[name=kind_id]').change(function(event) {
    ComponentSearch.form_submit();
  });
  
  $('form input.reset').click(function(event){
    ComponentSearch.form_reset();
    return false;
  });
  
  $('form input.submit').click(function(event){
    var input = $('#search_terms');
  
    if (input.val() != "") {
      $('#search_terms').autocomplete('close');
    
      var span = KorTemplate.get('.query_item');
      span.fill_in('.label', input.val());
      span.data('type', 'term');
      span.data('value', input.val());
      
      $('#term_queries').append(span);
      input.val("");
    }
    
    ComponentSearch.form_submit();
    return false;
  });
  
  this.setup_pagination();
}

ComponentSearch.string_to_values = function(string) {
  return [string]

  if (string[0] == "\"" || string[0] == "'") {
    return [string];
  } else {
    return string.split(/\s+/);
  }
}

ComponentSearch.autocomplete_enter_key = function(event) {
  if (event.which == '13') {
    var input = $(this);

    if (input.val() != "") {
      $('#search_terms').autocomplete('close');

      var values = ComponentSearch.string_to_values(input.val());
    
      for (var i = 0; i < values.length; i += 1) {
        var value = values[i];

        var span = KorTemplate.get('.query_item');
        span.fill_in('.label', value);
        span.data('type', 'term');
        span.data('value', value);
        
        $('#term_queries').append(span);
      }

      input.val("");
    }
    
    ComponentSearch.next_page = 1;
    
    ComponentSearch.form_submit();
    
    return false;
  }
}

ComponentSearch.autocomplete_source = function(request, response) {
  $.getJSON('/component/tag_counts', {kind_id: $('select[name=kind_id]').val(), term: request.term}, response);
}

ComponentSearch.autocomplete_select = function(event, ui) {
  var type = ui.item.value.split('|')[0];
  var values = ui.item.value.split('|').pop();
  values = ComponentSearch.string_to_values(values);

  for (var i = 0; i < values.length; i += 1) {
    var value = values[i];

    var span = KorTemplate.get('.query_item');
    span.data('type', type);
    span.data('value', value);
    span.fill_in('.label', span.data('value'));
    
    if (span.data('type') == 'term') {
      $('#term_queries').append(span);  
    } else {
      $('#tag_queries').append(span);  
    }
  }
  
  this.value = "";
  
  ComponentSearch.next_page = 1;
  
  return ComponentSearch.form_submit();
}

ComponentSearch.form_reset = function(event) {
  ComponentSearch.next_page = 1;
  ComponentSearch.clear_results();
  $('#term_queries .query_item, #tag_queries .query_item').remove();
}

ComponentSearch.form_submit = function(event) {
  var params = {
    'tags': [],
    'kind_id': $("select[name=kind_id]").val()
  };
    
  $("#term_queries .query_item, #tag_queries .query_item").map(function(i, e){
    e = $(e);
    
    if (e.data('type') == 'term') {
      params['terms'] = params['terms'] || []; 
      params['terms'].push(e.data('value'));
    } else {
      params['tags'].push(e.data('value'));
    }
  });
  
  if (ComponentSearch.next_page) {
    params['page'] = ComponentSearch.next_page;
  }
  
  ComponentSearch.re_search(params);
  
  return false;
}

ComponentSearch.re_search = function(params) {
  $.ajax({
    method: "get",
    url: '/component_search',
    data: params,
    success: function(data){
      ComponentSearch.results = data;
      ComponentSearch.results.pages = Math.floor(data.total / 10) + 1;
      ComponentSearch.draw();
    }
  })
}

ComponentSearch.clear_results = function() {
  $('.entity_list ul li').remove();
  $('div.count').remove();
}

ComponentSearch.draw_total = function() {
  var div = $("<div class='count'>").html(ComponentSearch.results.total + ' Treffer');
  $('.entity_list .title').after(div);
}

ComponentSearch.draw = function() {
  ComponentSearch.clear_results();
  ComponentSearch.draw_total();
  
  ComponentSearch.hash_to_results(this.results.entities).each(function(i, e){
    $('.entity_list ul').append($(e));
  });
  
  ComponentSearch.paginate();
}

ComponentSearch.setup_pagination = function() {
  var paginate = $('.entity_list div.pagination');
  var left = paginate.find('img[data-name=Pager_left]').parent();
  var right = paginate.find('img[data-name=pager_right]').parent();
  var select = paginate.find('select');
  var input = paginate.find('input');
  
  left.click(function(event) {
    return ComponentSearch.page_to(ComponentSearch.results.page - 1);
  });
  
  right.click(function(event) {
    return ComponentSearch.page_to(ComponentSearch.results.page + 1);
  });
  
  select.change(function(event) {
    return ComponentSearch.page_to($(event.currentTarget).val());
  });
  
  input.keypress(function(event) {
    if (event.which == 13) {
      $(event.currentTarget).trigger('change');
    } else if (event.which < 48 || event.which > 57) {
      return false;
    }
  });
  
  input.change(function(event) {
    return ComponentSearch.page_to($(event.currentTarget).val());
  });
}

ComponentSearch.page_to = function(page) {
  this.next_page = page;
  return this.form_submit();
}

ComponentSearch.paginate = function() {
  var paginate = $('.entity_list .pagination');

  if (this.results.total > 10) {
    var select = paginate.find('select');
    var input = paginate.find('input');
    var left = paginate.find('img[data-name=pager_left]').parent();
    var right = paginate.find('img[data-name=pager_right]').parent();
    
    var old_str = $('.pagination.ajax .amount').html();
    new_str = old_str.replace(/[\d]+/, ComponentSearch.results.pages);
    $('.pagination.ajax .amount').html(new_str);
    
    if (this.results.page == 1) {left.hide();} else {left.show();}
    if (this.results.page == this.results.pages) {right.hide();} else {right.show();}
    
    if (this.results.total > 10 * 20) {
      select.hide();
      input.show();
      input.val(this.results.page);      
    } else {
      input.hide();
      select.show();

      select.empty();
      var options = "";
      for (i = 1; i <= this.results.pages; i++) {
        options += '<option>' + i + '</option>';
      }
      select.append(options);

      select.val(this.results.page);
    }
    
    paginate.css('visibility', 'visible');
  } else {
    paginate.css('visibility', 'hidden');
  }
}

ComponentSearch.hash_to_results = function(hash) {
  return $(hash).map(function(i, e){
    return ComponentSearch.hash_to_result(e);
  });
}

ComponentSearch.hash_to_result = function(hash) {
  var tpl = KorTemplate.get('.search_result');
  tpl.attr('id', 'entity_' + hash.id);
  tpl.set('input', 'id', '/entity_' + hash.id);
  tpl.set('input', 'name', '/entity_' + hash.id);
  tpl.set('a', 'href', '/blaze#/entities/' + hash.id);
  tpl.set('a', 'target', '_blank');
  tpl.fill_in('.name', hash.name);
  tpl.fill_in('.kind', hash.kind);
  
  if (hash.images.length > 0) {
    var images_tpl = KorTemplate.get('.result_images');
    images_tpl.find('.result_image').remove();
    
    while (hash.images.length < 4) {
      hash.images.push({});
    }
    
    $(hash.images).each(function(i, e) {
      var image_tpl = KorTemplate.get('.result_images .result_image');
      image_tpl.set('.kor_medium_frame', 'id', 'kor_medium_frame_' + e.id);
      image_tpl.set('.kor_medium_frame > a', 'href', '/blaze#/entities/' + e.id);
      image_tpl.set('.kor_medium_frame > a', 'target', '_blank');
      image_tpl.set('.kor_medium_frame > a > img', 'src', e.url);
      images_tpl.find('tr.images').append(image_tpl);
    });
    
    tpl.append(images_tpl);
  }
  
  return tpl;
}

$(document).ready(function(event) {
  ComponentSearch.setup();
});
