<kor-legal>

  <div class="kor-layout-left kor-layout-large">
    <div class="kor-content-box">
      <div class="target"></div>

      <div if={!termsAccepted()}>
        <div class="hr"></div>

        <button>
          {tcap('commands.accept_terms')}
        </button>
      </div>
    </div>
  </div>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.config)
    tag.mixin(wApp.mixins.i18n)

    tag.on 'mount', ->
      Zepto(tag.root).find('.target').html tag.config().maintainer.legal_html

    tag.termsAccepted = ->
      tag.currentUser() && tag.currentUser().terms_accepted

    # tag.on 'mount', ->
    #   Zepto.ajax(
    #     url: '/legal'
    #     success: (data) -> 
    #       tag.text = data.text
    #       tag.update()
    #   )
  </script>
</kor-legal>