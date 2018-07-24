<kor-login-info>
  <div class="item">
    <span class="kor-shine">ConedaKOR</span>
    {t('nouns.version')}
    <span class="kor-shine">{info().version}</span>
  </div>

  <div class="item">
    {tcap('provided_by')}<br />
    <span class="kor-shine">{info().operator}</span>
  </div>

  <div class="item">
    {tcap('nouns.license')}<br />
    <a href="http://www.gnu.org/licenses/agpl-3.0.txt" target="_blank">
      {t('nouns.agpl')}
    </a>
  </div>

  <div class="item">
    »
    <a href={info().source_code_url} target="_blank">
      {t('objects.download', {interpolations: {o: 'nouns.source_code'}})}
    </a>
  </div>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.info);
  </script>
</kor-login-info>