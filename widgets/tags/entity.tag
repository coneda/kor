<kor-entity class="{medium: isMedium()}">

  <virtual if={isMedium()}>
    <kor-clipboard-control
      if={!opts.noClipboard}
      entity={opts.entity}
    />
    
    <a href="#/entities/{opts.entity.id}" class="to-medium">
      <img riot-src={opts.entity.medium.url.thumbnail} />
    </a>
    <div if={!opts.noContentType}>
      {t('nouns.content_type')}:
      <span class="content-type">{opts.entity.medium.content_type}</span>
    </div>
  </virtual>

  <virtual if={!isMedium()}>
    <a
      class="name"
      href="#/entities/{opts.entity.id}"
    >{opts.entity.display_name}</a>
    <span class="kind">{opts.entity.kind_name}</span>
  </virtual>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.info);

    tag.isMedium = function() {
      return tag.opts.entity && !!tag.opts.entity.medium_id;
    }
  </script>

</kor-entity>