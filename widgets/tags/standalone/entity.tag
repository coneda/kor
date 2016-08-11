<kor-entity class="kor {'kor-style': opts.korStyle}">
  
  <div class="auth" if={!authorized}>
    <strong>Info</strong>

    <p>
      It seems you are not allowed to see this content. Please
      <a href={login_url()}>login</a> to the kor installation first.
    </p>
  </div>

  <a href={url()} if={authorized} target="_blank">
    <div if={data.medium}>
      <img src={image_url()} />
      <em>{data.medium.content_type}, {human_size()} MiB</em>

    </div>
    <div if={!data.medium}>
      <h3>{data.display_name}</h3>
      <em>
        {data.kind_name}
        <span show={data.subtype}>({data.subtype})</span>
      </em>
    </div>
  </a>

  <style type="text/scss">
    @import "widgets/vars.scss";

    kor-entity, [data-is=kor-entity] {
      display: inline-block;

      &.kor-style {
        box-sizing: border-box;
        width: 200px;
        max-height: 200px;
        margin: 1rem;
        padding: 0.5rem;

        & > a {
          display: block;
          text-decoration: none;
        }

        h3 {
          margin: 0px;
          color: white;
        }

        img {
          max-width: 100%;
          max-height: 100%;
        }
      }
    }
  </style>

  <script type="text/coffee">
    self = this
    self.authorized = true

    self.on 'mount', ->
      if self.opts.id
        base = $('script[kor-url]').attr('kor-url') || ""

        $.ajax(
          type: 'get'
          url: "#{base}/entities/#{self.opts.id}"
          data: {include: 'all'}
          dataType: 'json'
          beforeSend: (xhr) -> xhr.withCredentials = true
          success: (data) ->
            # console.log data
            self.data = data
            self.update()
          error: (request) ->
            self.data = {}
            if request.status == 403
              self.authorized = false
              self.update()
        )
      else
        raise "this widget requires an id"

    self.login_url = ->
      base = $('script[kor-url]').attr('kor-url') || ""
      return_to = document.location.href
      "#{base}/login?return_to=#{return_to}"

    self.image_url = ->
      base = $('script[kor-url]').attr('kor-url') || ""
      "#{base}#{self.data.medium.url.preview}"

    self.url = ->
      base = $('[kor-url]').attr('kor-url') || ""
      "#{base}/blaze#/entities/#{self.data.id}"

    self.human_size = ->
      size = self.data.medium.file_size / 1024.0 / 1024.0;
      Math.floor(size * 100) / 100

  </script>

</kor-entity>