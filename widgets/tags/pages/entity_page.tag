<kor-entity-page>

  <div class="kor-layout-left kor-layout-large" if={data}>
    <div class="kor-content-box">
      <div class="kor-layout-commands page-commands">
        <kor-clipboard-control entity={data} />
        <virtual if={allowedTo('edit', data.collection_id)}>
          <a
            href="#/entities/{data.id}/edit"
            title={t('verbs.edit')}
          ><i class="fa fa-pencil"></i></a>
        </virtual>
        <a
          if={!data.medium && allowedTo('create')}
          href="#/entities/new?kind_id={data.kind_id}&clone_id={data.id}"
          title={t('verbs.clone')}
        ><i class="fa fa-copy"></i></a>
        <a
          href={reportUrl()}
          title={ tcap('objects.report', {interpolations: {o: 'activerecord.models.entity'}}) }
        ><i class="fa fa-exclamation"></i></a>
        <a
          if={allowedTo('delete', data.collection_id)}
          href="#/entities/{data.id}"
          onclick={delete}
          title={t('verbs.delete')}
        ><i class="fa fa-trash"></i></a>
      </div>
      <h1>
        {data.display_name}

        <div class="subtitle">
          <virtual if={data.medium && allowedTo('download_originals', data.collection_id)}>
            <span class="field">
              {tcap('activerecord.attributes.medium.original_extension')}:
            </span>
            <span class="value">{data.medium.content_type}</span>
          </virtual>
          <span if={!data.medium}>{data.kind.name}</span>
          <span if={data.subtype}>({data.subtype})</span>
        </div>
      </h1>

      <div if={data.medium}>
        <span class="field">
          {tcap('activerecord.attributes.medium.file_size')}:
        </span>
        <span class="value">{hs(data.medium.file_size)}</span>
      </div>

      <div if={data.synonyms.length > 0} field="synonyms">
        <span class="field">{tcap('nouns.synonym', {count: 'other'})}:</span>
        <span class="value">{data.synonyms.join(' | ')}</span>
      </div>

      <div each={dating in data.datings} dating-label={dating.label}>
        <span class="field">{dating.label}:</span>
        <span class="value">{dating.dating_string}</span>
      </div>

      <div each={field in fields()} field-name={field.name}>
        <virtual if={field.value}>
          <span class="field">{field.show_label}:</span>
          <span class="value">{fieldValue(field.value)}</span>
        </virtual>
      </div>

      <div show={visibleFields().length > 0} class="hr silent"></div>

      <div field="properties">
        <div each={property in data.properties}>
          <a
            if={property.url}
            href="{property.value}"
            rel="noopener"
            target="_blank"
          >» {property.label}</a>
          <virtual if={!property.url}>
            <span class="field">{property.label}:</span>
            <span class="value">{property.value}</span>
          </virtual>
        </div>
      </div>

      <div class="hr silent"></div>

      <div if={data.comment} class="comment" field="comment">
        <div class="field">
          {tcap('activerecord.attributes.entity.comment')}:
        </div>
        <div class="value"><pre>{data.comment}</pre></div>
      </div>

      <div
        each={generator in data.generators}
        generator-name={generator.name}
      >
        <kor-generator
          generator={generator}
          entity={data}
        />
      </div>

      <div class="hr silent"></div>

      <kor-inplace-tags
        entity={data}
        enable-editor={showTagging()}
        handlers={inplaceTagHandlers}
      />
    </div>

    <div class="kor-layout-bottom">
      <div class="kor-content-box relations">
        <div class="kor-layout-commands" if={allowedTo('edit')}>
          <a
            href="#"
            onclick={addRelationship}
            title={t('objects.add', {interpolations: {o: 'activerecord.models.relationship'}})}
          ><i class="fa fa-plus-square"></i></a>
        </div>
        <h1>{tcap('activerecord.models.relationship', {count: 'other'})}</h1>

        <div each={count, name in data.relations}>
          <kor-relation
            entity={data}
            name={name}
            total={count}
            ref="relations"
          />
        </div>
      </div>
    </div>

    <div
      class="kor-layout-bottom .meta"
      if={allowedTo('view_meta', data.collection_id)}
    >
      <div class="kor-content-box">
        <h1>
          {t('activerecord.attributes.entity.master_data', {capitalize: true})}
        </h1>

        <div>
          <span class="field">{t('activerecord.attributes.entity.uuid')}:</span>
          <span class="value">{data.uuid}</span>
        </div>

        <div if={data.created_at}>
          <span class="field">{t('activerecord.attributes.entity.created_at')}:</span>
          <span class="value">
            {l(data.created_at)}
            <span if={data.creator}>
              {t('by')}
              {data.creator.full_name || data.creator.name}
            </span>
          </span>
        </div>

        <div if={data.updated_at}>
          <span class="field">{t('activerecord.attributes.entity.updated_at')}:</span>
          <span class="value">
            {l(data.updated_at)}
            <span if={data.updater}>
              {t('by')}
              {data.updater.full_name || data.updater.name}
            </span>
          </span>
        </div>

        <div if={data.groups.length} class="groups">
          <span class="field">{t('activerecord.models.authority_group.other')}:</span>
          <ul>
            <li each={group in data.groups} class="value">
              <virtual if={group.directory}>
                <span each={dir in group.directory.ancestors}>
                  <a href="#/groups/categories/{dir.id}">{dir.name}</a> /
                </span>

                <a href="#/groups/categories/{group.directory.id}"><!--
                  -->{group.directory.name}<!--
                --></a> /
              </virtual>

              <a href="#/groups/admin/{group.id}">{group.name}</a>
            </li>
          </ul>
        </div>

        <div>
          <span class="field">{t('activerecord.models.collection')}:</span>
          <span class="value">{data.collection.name}</span>
        </div>

        <div>
          <span class="field">{t('activerecord.attributes.entity.degree')}:</span>
          <span class="value">{data.degree}</span>
        </div>

        <div class="hr"></div>

        <div class="kor-text-right kor-api-links">
          <a
            href={jsonUrl()}
            target="_blank"
          ><i class="fa fa-file-text"></i>{t('show_json')}</a><br />
          <a
            if={!isStatic()}
            href="/oai-pmh/entities.xml?verb=GetRecord&metadataPrefix=kor&identifier={data.uuid}"
            target="_blank"
          ><i class="fa fa-code"></i>{t('show_oai_pmh')}</a>
        </div>

      </div>
    </div>
  </div>

  <div class="kor-layout-right kor-layout-small">

    <div class="kor-content-box" if={data && data.medium_id}>
      <div class="viewer">
        <h1>{t('activerecord.models.medium', {capitalize: true})}</h1>

        <a href="#/media/{data.id}" title={t('larger')}>
          <img src="{data.medium.url.preview}">
        </a>

        <div if={allowedTo('edit', data.collection_id)} class="commands">
          <a
            each={op in ['flip', 'flop', 'rotate_cw', 'rotate_ccw', 'rotate_180']}
            href="#/media/{data.medium_id}/{op}"
            onclick={transform(op)}
            title={t('image_transformations.' + op)}
          ><i class="fa fa-{opIcon(op)}"></i></a>
        </div>


        <div class="formats">
          <a href="#/media/{data.id}">{t('verbs.enlarge')}</a>
          <span if={!data.medium.video && !data.medium.audio}> |
            <a
              href="{data.medium.url.normal}"
              target="_blank"
            >{t('verbs.maximize')}</a>
          </span>
          |
          <a
            href="{rootUrl()}/mirador?id={data.id}&manifest={rootUrl()}/mirador/{data.id}"
            onclick={openMirador}
          >{t('nouns.mirador')}</a>
          <br />
          {t('verbs.download')}:<br />
          <a
            if={allowedTo('download_originals', data.collection_id)}
            href={data.medium.url.original.replace(/\/images\//, '/download/')}
          >{t('nouns.original')} |</a>
          <a href={data.medium.url.normal.replace(/\/images\//, '/download/')}>
            {t('nouns.enlargement')}
          </a>
          <virtual if={!isStatic()}>
            |
            <a href="/entities/{data.id}/metadata">{t('nouns.metadata')}</a>
          </virtual>
        </div>

      </div>
    </div>

    <div class="kor-content-box" if={anyMediaRelations()}>
      <div class="related_images">
        <h1>
          {t('nouns.related_medium', {count: 'other', capitalize: true})}

          <div class="subtitle">
            <a
              if={allowedTo('create')}
              href="#/upload?relate_with={data.id}"
            >
              » {t('objects.add', {interpolations: {o: 'activerecord.models.medium.other'} } )}
            </a>
          </div>
        </h1>

        <div each={count, name in data.media_relations}>
          <kor-media-relation
            entity={data}
            name={name}
            total={count}
            on-updated={reload}
          />
        </div>

      </div>
    </div>
  </div>

  <div class="clearfix"></div>

<script type="text/javascript">
  let tag = this;
  tag.mixin(wApp.mixins.sessionAware);
  tag.mixin(wApp.mixins.i18n);
  tag.mixin(wApp.mixins.auth);
  tag.mixin(wApp.mixins.info);
  tag.mixin(wApp.mixins.page);

  // On mount, set up event listeners and fetch entity data
  tag.on('mount', function() {
    wApp.bus.on('relationship-updated', fetch);
    wApp.bus.on('relationship-created', fetch);
    wApp.bus.on('relationship-deleted', fetch);
    fetch();
  });

  // On unmount, remove event listeners
  tag.on('unmount', function() {
    wApp.bus.off('relationship-deleted', fetch);
    wApp.bus.off('relationship-created', fetch);
    wApp.bus.off('relationship-updated', fetch);
  });

  // Handle entity deletion
  tag.delete = function(event) {
    event.preventDefault();
    var message = tag.t('objects.confirm_destroy', {
      interpolations: { o: 'activerecord.models.entity' }
    });
    if (confirm(message)) {
      Zepto.ajax({
        type: 'DELETE',
        url: "/entities/" + tag.opts.id,
        success: function() {
          window.history.go(-1);
        }
      });
    }
  };

  // Get fields to display on the entity page
  tag.fields = function() {
    return tag.data.fields.filter(function(f) {
      return f.show_on_entity;
    });
  };

  // Get visible fields with values
  tag.visibleFields = function() {
    return tag.fields().filter(function(f) {
      return f.value;
    });
  };

  // Check if tagging is allowed
  tag.showTagging = function() {
    return tag.data.kind.tagging && tag.allowedTo('tagging', tag.data.collection_id);
  };

  tag.anyMediaRelations = function() {
    if (!tag.data) return false

    const relCount = Object.keys(tag.data.media_relations).length

    return tag.allowedTo('create') || relCount > 0
  }

  tag.jsonUrl = function() {
    return (
      tag.isStatic() ?
      `static/entities/${tag.data.id}.json` :
      `entities/${tag.data.id}.json`
    )
  }

  // Handle media transformations
  tag.transform = function(op) {
    return function(event) {
      event.preventDefault();
      Zepto.ajax({
        type: 'PATCH',
        url: "/media/transform/" + tag.data.medium_id + "/image/" + op,
        success: function() {
          tag.data.medium.url.preview += '?cb=' + new Date().getTime();
          tag.update();
        }
      });
    };
  };

  // Get icon for media transformation operations
  tag.opIcon = function(op) {
    return {
      'flip': 'arrows-v',
      'flop': 'arrows-h',
      'rotate_cw': 'mail-reply fa-flip-horizontal',
      'rotate_ccw': 'mail-reply',
      'rotate_180': 'circle-o-notch fa-flip-vertical'
    }[op];
  };

  // Generate report URL for the entity
  tag.reportUrl = function() {
    var to = wApp.config.data.values.maintainer_mail;
    var subject = tag.t('messages.report_entity_subject');
    var body = tag.t('messages.report_entity_body', {
      interpolations: {
        entity_url: wApp.info.data.url + "#/entities/" + tag.data.id,
        user: wApp.session.current.user.name
      }
    });
    return "mailto:" + to + "?subject=" + subject + "&body=" + encodeURIComponent(body);
  };

  // Add a relationship to the entity
  tag.addRelationship = function(event) {
    event.preventDefault();
    wApp.bus.trigger('modal', 'kor-relationship-editor', {
      directedRelationship: { from_id: tag.data.id },
      onCreated: tag.reload
    });
  };

  // Open Mirador viewer
  tag.openMirador = function(event) {
    event.preventDefault();
    event.stopPropagation();
    var url = Zepto(event.target).attr('href');
    window.open(url, '', 'height=800,width=1024');
  };

  // Format field value
  tag.fieldValue = function(value) {
    return Array.isArray(value) ? value.join(', ') : value;
  };

  // Fetch entity data from the server
  var fetch = function() {
    Zepto.ajax({
      url: "/entities/" + tag.opts.id,
      data: { include: 'all' },
      success: function(data) {
        tag.data = data;

        // Force re-mounting of kor-relation tags
        var rels = tag.data.relations;
        tag.data.relations = {};
        tag.update();
        tag.data.relations = rels;

        tag.title(tag.data.display_name);
        linkifyProperties();
        wApp.entityHistory.add(data.id);
      },
      error: function() {
        wApp.bus.trigger('access-denied');
      },
      complete: function() {
        tag.update();
      }
    });
  }

  // Handlers for inplace tags
  tag.inplaceTagHandlers = {
    doneHandler: function() {
      fetch();
    }
  };

  // Linkify properties with URLs
  var linkifyProperties = function() {
    for (var i = 0; i < tag.data.properties.length; i++) {
      var property = tag.data.properties[i];
      if (typeof property.value === 'string') {
        if (property.value.match(/^https?:\/\//)) {
          property.url = true;
        }
      }
    }
  };
</script>

</kor-entity-page>
