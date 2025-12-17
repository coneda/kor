<kor-nothing-found show={!opts.data || opts.data.total == 0}>

  <span>{t('no_results')}</span>

  <script type="text/javascript">
    let tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
  </script>

</kor-nothing-found>