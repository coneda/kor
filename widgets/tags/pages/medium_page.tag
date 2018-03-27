<kor-medium-page>

  <div class="kor-content-box">
    <a if={data} href="#/entities/{data.id}">
      <img if={!data.medium.video &&! data.medium.audio} src="{data.medium.url.screen}" />
      <video if={data.medium.video} controls mute autoplay>
        <source riot-src={data.medium.url['video/mp4']} type="video/mp4">
        <source riot-src={data.medium.url['video/webm']} type="video/webm">
        <source riot-src={data.medium.url['video/ogg']} type="video/ogg">
      </video>
      <audio if={data.medium.audio} controls>
        <source src={data.medium.url['audio/mp3']} type="audio/mp3">
        <source src={data.medium.url['audio/ogg']} type="audio/ogg">
      </audio>
    </a>
  </div>

  <script type="text/javascript">
    var tag = this;
    tag.mixin(wApp.mixins.sessionAware);
    tag.mixin(wApp.mixins.i18n);

    tag.on('mount', function() {
      fetch();
    })

    var fetch = function() {
      Zepto.ajax({
        url: '/entities/' + tag.opts.id,
        data: {includes: 'medium'},
        success: function(data) {
          tag.data = data;
          tag.update();
        }
      })
    }
  </script>

</kor-medium-page>