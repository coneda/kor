<kor-entity-page>

  <div class="kor-layout-left kor-layout-large" if={data}>
    <div class="kor-content-box">
      <div class="kor-layout-commands">
        <virtual if={allowedTo('edit', data.collection_id)}>
          <kor-clipboard-control entity={data} />
          <a href="#/entities/{data.id}/edit"><i class="pen"></i></a>
        </virtual>
        <a
          if={allowedTo('edit', data.collection_id)}
          onclick={delete}
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
        <span class="value">{field.value}</span>
      </div>

      <div show={visibleFields().length > 0} class="hr silent"></div>

      <div each={property in data.properties}>
        <span class="field">{property.label}:</span>
        <span class="value">{property.value}</span>
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
      <div class="kor-content-box">
        <div class="kor-layout-commands" if={allowedTo('edit')}>
          <a><i class="plus"></i></a>
        </div>
        <h1>{tcap('activerecord.models.relationship', {count: 'other'})}</h1>

        <div each={count, name in data.relations}>
          <kor-relation
            entity={data}
            name={name}
            total={count}
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

    tag.on 'mount', ->
      fetch()

    tag.delete = (event) ->
      event.preventDefault()
      message = tag.t('objects.confirm_destroy',
        interpolations: {o: 'activerecord.models.entity'}
      )
      if confirm(message)
        console.log 'deleting'

    tag.visibleFields = ->
      f for f in tag.data.fields when f.value && f.show_on_entity

    tag.showTagging = ->
      tag.data.kind.settings.tagging == '1' && 
      (
        tag.data.tags.length > 0 ||
        tag.allowedTo('tagging', tag.data.collection_id)
      )

    fetch = ->
      Zepto.ajax(
        url: "/entities/#{tag.opts.id}"
        data: {include: 'all'}
        success: (data) ->
          tag.data = data
        error: ->
          h() if h = tag.opts.handlers.accessDenied
        complete: ->
          tag.update()
      )

    tag.inplaceTagHandlers = {
      doneHandler: fetch
    }

  </script>

</kor-entity-page>