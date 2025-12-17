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

<script type="text/javascript">
  let tag = this;
  tag.authorized = true;

  // On mount, fetch entity data if ID is provided
  tag.on('mount', function() {
    if (tag.opts.id) {
      var base = $('script[kor-url]').attr('kor-url') || "";

      Zepto.ajax({
        url: base + "/entities/" + tag.opts.id,
        data: { include: 'all' },
        dataType: 'json',
        beforeSend: function(xhr) {
          xhr.withCredentials = true;
        },
        success: function(data) {
          tag.data = data;
          tag.update();
        },
        error: function(request) {
          tag.data = {};
          if (request.status === 403) {
            tag.authorized = false;
            tag.update();
          }
        }
      });
    } else {
      throw new Error("This widget requires an ID");
    }
  });

  // Generate login URL
  tag.login_url = function() {
    var base = $('script[kor-url]').attr('kor-url') || "";
    var return_to = document.location.href;
    return base + "/login?return_to=" + return_to;
  };

  // Get image size
  tag.image_size = function() {
    return tag.opts.korImageSize || 'preview';
  };

  // Generate image URL
  tag.image_url = function() {
    var base = $('script[kor-url]').attr('kor-url') || "";
    var size = tag.image_size();
    return base + tag.data.medium.url[size];
  };

  // Check if a specific feature is included
  tag.include = function(what) {
    var includes = (tag.opts.korInclude || "").split(/\s+/);
    return includes.indexOf(what) !== -1;
  };

  // Generate entity URL
  tag.url = function() {
    var base = $('[kor-url]').attr('kor-url') || "";
    return base + "/blaze#/entities/" + tag.data.id;
  };

  // Calculate human-readable file size
  tag.human_size = function() {
    var size = tag.data.medium.file_size / 1024.0 / 1024.0;
    return Math.floor(size * 100) / 100;
  };
</script>

</kor-sa-entity>