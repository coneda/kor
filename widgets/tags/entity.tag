<kor-entity class="{medium: isMedium()}">

  <virtual if={isMedium()}>
    <div class="buttons">
      <kor-clipboard-control
        if={!opts.noClipboard}
        entity={opts.entity}
      />
      <kor-remove-from-group
        if={opts.authorityGroupId || opts.userGroupId}
        type={opts.authorityGroupId ? 'authority' : 'user'}
        group-id={opts.authorityGroupId || opts.userGroupId}
        entity={opts.entity}
      />
    </div>
    
    <a href="#/entities/{opts.entity.id}" class="to-medium">
      <img riot-src={imageUrl()} />
    </a>
    <div if={!opts.noContentType}>
      {tcap('nouns.content_type')}:
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

    tag.imageUrl = function() {
      var base = opts.entity.medium.url.thumbnail;

      if (tag.opts.publishment) {
        return base.replace(/\?([0-9]+)$/, '?uuid=' + tag.opts.publishment + '&$1');
      } else {
        return base;
      }
    }
  </script>

</kor-entity>