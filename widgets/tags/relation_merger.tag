<kor-relation-merger>
  {wApp.i18n.t('messages.relation_merger_prompt')}

  <ul if={ids(true).length > 0}>
    <li each={relation, id in relations}>
      <a
        href="#"
        onclick={setAsTarget}
      >{relation.name} / {relation.reverse_name}</a>
      ({relation.id})
      <i if={relation.id == target} class="fa fa-star"></i>
      <a
        href="#"
        onclick={removeRelation}
      ><i class="fa fa-times"></i></a>
    </li>
  </ul>

  <div class="text-right" if={valid()}>
    <button onclick={check}>{wApp.i18n.t('verbs.check')}</button>
    <button onclick={merge}>{wApp.i18n.t('verbs.merge')}</button>
  </div>

  <script type="text/javascript">
    var tag = this;
    tag.relations = {};
    tag.target = null;
    window.t = tag;

    tag.addRelation = function(relation) {
      tag.relations[relation.id] = relation;
      tag.update();
    }

    tag.removeRelation = function(id) {
      event.preventDefault();
      var id = event.item.relation.id;
      delete tag.relations[id];
      if (tag.target == id) {
        tag.target = null;
      }
      tag.update();
    }

    tag.setAsTarget = function(event) {
      event.preventDefault();
      var id = event.item.relation.id;
      tag.target = id;
      tag.update();
    }

    tag.ids = function(includeTarget) {
      var results = [];
      Zepto.each(tag.relations, function(k, v) {
        k = parseInt(k);
        if (includeTarget || k != tag.target) {
          results.push(k);
        }
      });
      return results;
    }

    tag.valid = function() {
      return tag.target && tag.ids().length > 0
    }

    tag.check = function() {submit(true)}
    tag.merge = function() {
      if (window.confirm(wApp.i18n.t('confirm.long_time_warning'))) {
        submit(false);
      }
    }

    var done = function() {
      var h = tag.opts.onDone;
      if (h) {h()}
    }

    var submit = function(check_only) {
      var params = {other_id: tag.ids()};
      if (check_only != false) {
        params['check_only'] = true;
      }

      Zepto.ajax({
        type: 'POST',
        url: '/relations/' + tag.target + '/merge',
        data: JSON.stringify(params),
        success: function(data) {
          if (check_only == false) {
            done();
          }
        },
        error: function() {
          console.log(arguments);
        }
      });
    }

  </script>
</kor-relation-merger>