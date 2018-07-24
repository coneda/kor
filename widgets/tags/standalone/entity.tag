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
    tag = this
    tag.authorized = true

    tag.on 'mount', ->
      if tag.opts.id
        base = $('script[kor-url]').attr('kor-url') || ""

        Zepto.ajax(
          url: "#{base}/entities/#{tag.opts.id}"
          data: {include: 'all'}
          dataType: 'json'
          beforeSend: (xhr) -> xhr.withCredentials = true
          success: (data) ->
            # console.log data
            tag.data = data
            tag.update()
          error: (request) ->
            tag.data = {}
            if request.status == 403
              tag.authorized = false
              tag.update()
        )
      else
        raise "this widget requires an id"

    tag.login_url = ->
      base = $('script[kor-url]').attr('kor-url') || ""
      return_to = document.location.href
      "#{base}/login?return_to=#{return_to}"

    tag.image_size = ->
      tag.opts.korImageSize || 'preview'

    tag.image_url = ->
      base = $('script[kor-url]').attr('kor-url') || ""
      size = tag.image_size()
      "#{base}#{tag.data.medium.url[size]}"

    tag.include = (what) ->
      includes = (tag.opts.korInclude || "").split(/\s+/)
      includes.indexOf(what) != -1

    tag.url = ->
      base = $('[kor-url]').attr('kor-url') || ""
      "#{base}/blaze#/entities/#{tag.data.id}"

    tag.human_size = ->
      size = tag.data.medium.file_size / 1024.0 / 1024.0;
      Math.floor(size * 100) / 100

  </script>

</kor-sa-entity>