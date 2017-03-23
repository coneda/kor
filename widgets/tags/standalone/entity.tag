<kor-sa-entity class="{'kor-style': opts.korStyle, 'kor': opts.korStyle}">
  
  <div class="auth" if={!authorized}>
    <strong>Info</strong>

    <p>
      It seems you are not allowed to see this content. Please
      <a href={login_url()}>login</a> to the kor installation first.
    </p>
  </div>

  <a href={url()} if={authorized} target="_blank">
    <img if={data.medium} src={image_url()} />
    <div if={!data.medium}>
      <h3>{data.display_name}</h3>
      <em if={include('kind')}>
        {data.kind_name}
        <span show={data.subtype}>({data.subtype})</span>
      </em>
    </div>
  </a>

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

    self.image_size = ->
      self.opts.korImageSize || 'preview'

    self.image_url = ->
      base = $('script[kor-url]').attr('kor-url') || ""
      size = self.image_size()
      "#{base}#{self.data.medium.url[size]}"

    self.include = (what) ->
      includes = (self.opts.korInclude || "").split(/\s+/)
      includes.indexOf(what) != -1

    self.url = ->
      base = $('[kor-url]').attr('kor-url') || ""
      "#{base}/blaze#/entities/#{self.data.id}"

    self.human_size = ->
      size = self.data.medium.file_size / 1024.0 / 1024.0;
      Math.floor(size * 100) / 100

  </script>

</kor-sa-entity>