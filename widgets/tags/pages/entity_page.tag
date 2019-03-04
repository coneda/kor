<kor-entity-page>

  <div class="kor-layout-left kor-layout-large" if={data}>
    <div class="kor-content-box">
      <div class="kor-layout-commands page-commands">
        <kor-clipboard-control entity={data} />
        <virtual if={allowedTo('edit', data.collection_id)}>
          <a
            href="#/entities/{data.id}/edit"
            title={t('verbs.edit')}
          ><i class="pen"></i></a>
        </virtual>
        <a
          if={allowedTo('edit', data.collection_id)}
          href="#/entities/{data.id}"
          onclick={delete}
          title={t('verbs.delete')}
        ><i class="x"></i></a>
      </div>
      <h1>
        {data.display_name}

        <div class="subtitle">
          <virtual if={data.medium}>
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

      <div if={data.synonyms.length > 0}>
        <span class="field">{tcap('nouns.synonym', {count: 'other'})}:</span>
        <span class="value">{data.synonyms.join(' | ')}</span>
      </div>

      <div each={dating in data.datings}>
        <span class="field">{dating.label}:</span>
        <span class="value">{dating.dating_string}</span>
      </div>

      <div each={field in visibleFields()}>
        <span class="field">{field.show_label}:</span>
        <span class="value">{fieldValue(field.value)}</span>
      </div>

      <div show={visibleFields().length > 0} class="hr silent"></div>

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

      <div class="hr silent"></div>

      <div if={data.comment} class="comment">
        <div class="field">
          {tcap('activerecord.attributes.entity.comment')}:
        </div>
        <div class="value"><pre>{data.comment}</pre></div>
      </div>

      <kor-generator
        each={generator in data.generators}
        generator={generator}
        entity={data}
      />

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
          ><i class="plus"></i></a>
        </div>
        <h1>{tcap('activerecord.models.relationship', {count: 'other'})}</h1>

        <div each={count, name in data.relations}>
          <kor-relation
            entity={data}
            name={name}
            total={count}
            on-updated={reload}
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

        <div if={data.groups.length}>
          <span class="field">{t('activerecord.models.authority_group.other')}:</span>
          <span class="value">{authorityGroups()}</span>
        </div>

        <div>
          <span class="field">{t('activerecord.models.collection')}:</span>
          <span class="value">{data.collection.name}</span>
        </div>

        <div>
          <span class="field">{t('activerecord.attributes.entity.degree')}:</span>
          <span class="value">{data.degree}</span>
        </div>

        <hr />

        <div class="kor-text-right">
          <a href="/entities/{data.id}.json" target="_blank">
            <i class="fa fa-file-text"></i>
            {t('show_json')}
          </a>
          <br />
          <a href="/oai-pmh/entities.xml?verb=GetRecord&metadataPrefix=kor&identifier={data.uuid}" target="_blank">
            <i class="fa fa-code"></i>
            {t('show_oai_pmh')}
          </a>
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

        <div class="commands">
          <a
            each={op in ['flip', 'flop', 'rotate_cw', 'rotate_ccw', 'rotate_180']}
            href="#/media/{data.medium_id}/{op}"
            onclick={transform(op)}
            title={t('image_transformations.' + op)}
          ><i class="{op}"></i></a>
        </div>

        
        <div class="formats">
          <a href="#/media/{data.medium.id}">{t('verbs.enlarge')}</a>
          <span if={!data.medium.video && !data.medium.audio}> |
            <a
              href="{data.medium.url.normal}"
              target="_blank"
            >{t('verbs.maximize')}</a>
          </span>
          |
          <a
            href="{rootUrl()}mirador?manifest={rootUrl()}mirador/{data.id}"
            onclick={openMirador}
          >{t('nouns.mirador')}</a>
          <br />
          {t('verbs.download')}:<br />
          <a 
            if={allowedTo('download_originals', data.collection_id)}
            href={data.medium.url.original}
          >{t('nouns.original')}</a> |
          <a href={data.medium.url.normal.replace(/\/images\//, '/download/')}>
            {t('nouns.enlargement')}
          </a> |
          <a href="/entities/{data.id}/metadata">{t('nouns.metadata')}</a>
        </div>

      </div>
    </div>

    <div class="kor-content-box" if={data}>
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

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.mixin(wApp.mixins.auth)
    tag.mixin(wApp.mixins.info)
    tag.mixin(wApp.mixins.page)

    tag.on 'mount', ->
      wApp.bus.on 'relationship-updated', fetch
      wApp.bus.on 'relationship-created', fetch
      fetch()

    tag.on 'unmount', ->
      wApp.bus.off 'relationship-created', fetch
      wApp.bus.off 'relationship-updated', fetch

    tag.delete = (event) ->
      event.preventDefault()
      message = tag.t('objects.confirm_destroy',
        interpolations: {o: 'activerecord.models.entity'}
      )
      if confirm(message)
        Zepto.ajax(
          type: 'DELETE'
          url: "/entities/#{tag.opts.id}"
          success: -> window.history.go(-1)
        )

    tag.visibleFields = ->
      f for f in tag.data.fields when f.value && f.show_on_entity

    tag.authorityGroups = ->
      (g.name for g in tag.data.groups).join(', ')

    tag.showTagging = ->
      tag.data.kind.tagging && 
        tag.allowedTo('tagging', tag.data.collection_id)

    tag.transform = (op) ->
      (event) ->
        event.preventDefault()

        Zepto.ajax(
          type: 'PATCH'
          url: "/media/transform/#{tag.data.medium_id}/image/#{op}"
          success: ->
            tag.data.medium.url.preview += '?cb=' + (new Date()).getTime()
            tag.update()
        )

    tag.addRelationship = (event) ->
      event.preventDefault()
      wApp.bus.trigger 'modal', 'kor-relationship-editor', {
        directedRelationship: {from_id: tag.data.id},
        onCreated: tag.reload
      }

    tag.openMirador = (event) ->
      event.preventDefault()
      event.stopPropagation()

      url = Zepto(event.target).attr('href')
      window.open(url, '', 'height=800,width=1024')

    tag.fieldValue = (value) ->
      if Zepto.isArray(value) then value.join(', ') else value

    fetch = ->
      Zepto.ajax(
        url: "/entities/#{tag.opts.id}"
        data: {include: 'all'}
        success: (data) ->
          tag.data = data
          tag.title tag.data.display_name
          linkify_properties()
        error: ->
          wApp.bus.trigger('access-denied')
        complete: ->
          tag.update()
      )

    tag.inplaceTagHandlers = {
      doneHandler: fetch
    }

    linkify_properties = ->
      for property in tag.data.properties
        if typeof(property['value']) == 'string'
          if property['value'].match(/^https?:\/\//)
            property['url'] = true

  </script>

</kor-entity-page>