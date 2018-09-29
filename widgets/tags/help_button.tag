<kor-help-button>
  <a
    if={hasHelp()}
    href="#"
    onclick={click}
    title={t('nouns.help')}
  ><i class="help"></i></a>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);

    tag.click = function(event) {
      event.preventDefault();
      wApp.config.showHelp(tag.opts.key);
    }

    tag.hasHelp = function() {
      return wApp.config.hasHelp(tag.opts.key);
    }
  </script>
</kor-help-button>