var Pagination = new Object();
Pagination.Entity = new Object();
Pagination.Gallery = new Object();

$(document).ready(function(event){
  Pagination.Entity.register_events();

  if (!window.location.pathname.match(/component_search/)) {
    Pagination.Gallery.register_events('.entity_list');
  }
  
  Pagination.Gallery.register_events('.gallery');

  if (window.location.pathname.match(/\/entities\/invalid/)) {
    Pagination.Gallery.register_events('.section_panel');
  }
});

Pagination.Gallery.register_events = function(scope) {
  $(scope + ' .pagination select').change(function(event){
    var select = $(event.currentTarget);
    var page = select.val();
    
    Pagination.Gallery.page_to(page);
  });
  
  var left = $(scope + ' .pagination img[Alt=Pager_left]').parent();
  var right = $(scope + ' .pagination img[Alt=Pager_right]').parent();
  
  left.click(function(event){
    var link = $(event.currentTarget);
    var select = link.parents('.pagination').find('select');
    
    var values = select.find('option').map(function(i, o){return($(o).val());});
    var current_value = select.val();
    
    if (values[0] != current_value) {
      select.val(select.val() - 1);
      select.change();
    }
    
    return(false);
  });
  
  right.click(function(event){
    var link = $(event.currentTarget);
    var select = link.parents('.pagination').find('select');
    
    var values = select.find('option').map(function(i, o){return($(o).val());});
    var current_value = select.val();
    
    if (values.last()[0] != current_value) {
      select.val(parseInt(current_value) + 1);
      select.change();
    }
    
    return(false);
  });
}

Pagination.Gallery.page_to = function(page) {
  var loc = document.location.href + '';
  var new_param = 'page=' + page;
  var new_loc = null;

  if (loc.match(/\?.*page\=/)) {
    new_loc = loc.replace(/page\=[0-9]+/, new_param);
  } else if (loc.match(/\?/)) {
    new_loc = loc + '&' + new_param;
  } else {
    new_loc = loc + '?' + new_param;
  }
  
  document.location.href = new_loc;
}

Pagination.Entity.register_events = function() {
  $('.relation .pagination select').change(function(event){
    var relation = $(event.currentTarget).parents('.relation');
    var select = $(event.currentTarget)
    var page = select.val();
    
    Pagination.Entity.page_to(relation, select, page);
  });
  
  var left = $('.relation .pagination img[Alt=Pager_left]').parent();
  var right = $('.relation .pagination img[Alt=Pager_right]').parent();
  
  left.click(function(event){
    var link = $(event.currentTarget);
    var relation = link.parents('.relation');
    var select = link.parents('.pagination').find('select');
    
    var values = select.find('option').map(function(i, o){return($(o).val());});
    var current_value = select.val();
    
    if (values[0] != current_value) {
      select.val(select.val() - 1);
      select.change();
    }
    
    return(false);
  });
  
  right.click(function(event){
    var link = $(event.currentTarget);
    var relation = link.parents('.relation');
    var select = link.parents('.pagination').find('select');
    
    var values = select.find('option').map(function(i, o){return($(o).val());});
    var current_value = select.val();
    
    if (values.last()[0] != current_value) {
      select.val(parseInt(current_value) + 1);
      select.change();
    }
    
    return(false);
  });
}

Pagination.Entity.page_to = function(relation, select, page) {
  Pagination.Entity.synchronize_pagination_selectors(select.attr('name'), select.val());
  
  var entity_id = document.location.href.split('/').pop();
  var relation_name = relation.find('> .subtitle').html();
  
  $.ajax({
    url: '/entities/' + entity_id + '/relationships',
    data: {page: page, relation_name: relation_name},
    dataType: 'text',
    context: relation,
    success: function(data){
      var relation = $(this);
      var counter = relation.attr('id').split('_').pop();
      
      $('#current_' + counter + '_page').html(data);
      
      Pagination.Entity.reset_images_shown(relation);
    }
  });
}

Pagination.Entity.reset_images_shown = function(element) {
  Pagination.Entity.reset_custom_state(element, 'images_shown');
  Pagination.Entity.reset_image(element.find('div.relation_switch img'), '/images/triangle_up.gif');
}

Pagination.Entity.reset_custom_state = function(element, state_property) {
  element.attr(state_property, 'no');
}

Pagination.Entity.reset_image = function(image, path) {
  image.attr('src', path);
}

Pagination.Entity.synchronize_pagination_selectors = function(name, value) {
  $("select[name=" + name + "]").each(function(i, s){
    $(s).val(value);
  });
}

