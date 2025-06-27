<kor-legal>

  <div class="kor-layout-left kor-layout-large">
    <div class="kor-content-box">
      <div class="target"></div>

      <div if={!termsAccepted()}>
        <div class="hr"></div>

        <button onclick={submit}>
          {tcap('commands.accept_terms')}
        </button>
      </div>
    </div>
  </div>
  
  <div class="clearfix"></div>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.config);
    tag.mixin(wApp.mixins.i18n);
    tag.mixin(wApp.mixins.page);

    tag.on('mount', function() {
      tag.title(tag.t('legal'));
      Zepto(tag.root).find('.target').html(tag.config().legal_html);
    });

    tag.termsAccepted = function() {
      return tag.currentUser() && tag.currentUser().terms_accepted;
    };

    tag.submit = function() {
      Zepto.ajax({
        url: '/users/accept_terms',
        type: 'PATCH',
        success: function(data) {
          wApp.bus.trigger('reload-session');
        }
      });
    };
  </script>
</kor-legal>