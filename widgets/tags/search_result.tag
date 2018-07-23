<kor-search-result>

  <a href="#/entities/{opts.entity.id}" class="to-entity">
    <kor-clipboard-control entity={opts.entity} />

    <div class="labels">
      <div class="name">{opts.entity.display_name}</div>
      <div class="kind">{opts.entity.kind_name}</div>
    </div>

    <div class="media" if={opts.entity.related.length > 0}>
      <kor-entity
        each={rel in opts.entity.related}
        entity={rel.to}
        no-content-type={true}
      />
      <div class="clearfix"></div>
    </div>
  </a>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
  </script>

</kor-search-result>