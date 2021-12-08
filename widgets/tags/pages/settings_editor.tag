<kor-settings-editor>

  <div class="kor-layout-left kor-layout-large">
    <div class="kor-content-box">
      <h1>
        {tcap('activerecord.models.setting', {count: 'other'})}
      </h1>

      <form onsubmit={submit} if={values && groups && relations}>
        <h2>{tcap('settings.branding_and_display')}</h2>
        <div class="hr"></div>

        <kor-input
          name="maintainer_name"
          label={nameFor('maintainer_name')}
          riot-value={valueWithDefaults('maintainer_name')}
          ref="fields"
        />

        <kor-input
          name="maintainer_mail"
          label={nameFor('maintainer_mail')}
          riot-value={valueWithDefaults('maintainer_mail')}
          ref="fields"
        />

        <kor-input
          name="welcome_title"
          label={nameFor('welcome_title')}
          riot-value={valueWithDefaults('welcome_title')}
          ref="fields"
        />

        <kor-input
          name="welcome_text"
          label={nameFor('welcome_text')}
          type="textarea"
          riot-value={valueWithDefaults('welcome_text')}
          ref="fields"
        />

        <kor-input
          name="welcome_page_only_media"
          label={nameFor('welcome_page_only_media')}
          type="checkbox"
          riot-value={valueWithDefaults('welcome_page_only_media')}
          ref="fields"
        />

        <kor-input
          name="legal_text"
          label={nameFor('legal_text')}
          type="textarea"
          riot-value={valueWithDefaults('legal_text')}
          ref="fields"
        />

        <kor-input
          name="about_text"
          label={nameFor('about_text')}
          type="textarea"
          riot-value={valueWithDefaults('about_text')}
          ref="fields"
        />

        <kor-input
          name="custom_css_file"
          label={nameFor('custom_css_file')}
          riot-value={valueWithDefaults('custom_css_file')}
          ref="fields"
        />

        <kor-input
          name="new_media_label"
          type="select"
          options={newMediaLabels()}
          label={nameFor('new_media_label')}
          riot-value={valueWithDefaults('new_media_label')}
          ref="fields"
        />

        <kor-input
          name="env_auth_button_label"
          label={nameFor('env_auth_button_label')}
          riot-value={valueWithDefaults('env_auth_button_label')}
          ref="fields"
        />

        <kor-input
          name="search_entity_name"
          label={nameFor('search_entity_name')}
          riot-value={valueWithDefaults('search_entity_name')}
          ref="fields"
        />

        <kor-input
          name="kind_dating_label"
          label={nameFor('kind_dating_label')}
          riot-value={valueWithDefaults('kind_dating_label')}
          ref="fields"
        />

        <kor-input
          name="kind_name_label"
          label={nameFor('kind_name_label')}
          riot-value={valueWithDefaults('kind_name_label')}
          ref="fields"
        />

        <kor-input
          name="kind_distinct_name_label"
          label={nameFor('kind_distinct_name_label')}
          riot-value={valueWithDefaults('kind_distinct_name_label')}
          ref="fields"
        />

        <kor-input
          name="relationship_dating_label"
          label={nameFor('relationship_dating_label')}
          riot-value={valueWithDefaults('relationship_dating_label')}
          ref="fields"
        />

        <kor-input
          name="primary_relations"
          label={nameFor('primary_relations')}
          type="select"
          multiple={true}
          options={relations}
          riot-value={valueWithDefaults('primary_relations')}
          ref="fields"
          help={tcap('help.primary_relations')}
        />

        <kor-input
          name="secondary_relations"
          label={nameFor('secondary_relations')}
          type="select"
          multiple={true}
          options={relations}
          riot-value={valueWithDefaults('secondary_relations')}
          ref="fields"
          help={tcap('help.secondary_relations')}
        />

        <h2>{tcap('settings.behavior')}</h2>
        <div class="hr"></div>

        <kor-input
          name="default_locale"
          label={nameFor('default_locale')}
          type="select"
          options={wApp.i18n.locales()}
          riot-value={valueWithDefaults('default_locale')}
          ref="fields"
        />

        <kor-input
          name="max_foreground_group_download_size"
          label={nameFor('max_foreground_group_download_size')}
          type="number"
          riot-value={valueWithDefaults('max_foreground_group_download_size')}
          ref="fields"
        />

        <kor-input
          name="max_file_upload_size"
          label={nameFor('max_file_upload_size')}
          type="number"
          riot-value={valueWithDefaults('max_file_upload_size')}
          ref="fields"
        />

        <kor-input
          name="max_results_per_request"
          label={nameFor('max_results_per_request')}
          type="number"
          riot-value={valueWithDefaults('max_results_per_request')}
          ref="fields"
        />

        <kor-input
          name="max_included_results_per_result"
          label={nameFor('max_included_results_per_result')}
          type="number"
          riot-value={valueWithDefaults('max_included_results_per_result')}
          ref="fields"
        />

        <kor-input
          name="session_lifetime"
          label={nameFor('session_lifetime')}
          type="number"
          riot-value={valueWithDefaults('session_lifetime')}
          ref="fields"
        />

        <kor-input
          name="publishment_lifetime"
          label={nameFor('publishment_lifetime')}
          type="number"
          riot-value={valueWithDefaults('publishment_lifetime')}
          ref="fields"
        />

        <kor-input
          name="default_groups"
          label={nameFor('default_groups')}
          type="select"
          multiple={true}
          options={groups}
          riot-value={valueWithDefaults('default_groups')}
          ref="fields"
        />

        <kor-input
          name="max_download_group_size"
          label={nameFor('max_download_group_size')}
          type="number"
          riot-value={valueWithDefaults('max_download_group_size')}
          ref="fields"
        />

        <kor-input
          name="wikidata_integration"
          label={nameFor('wikidata_integration')}
          help={tcap('help.wikidata_integration')}
          type="text"
          riot-value={valueWithDefaults('wikidata_integration')}
          ref="fields"
        />

        <kor-input
          name="create_missing_relations"
          label={nameFor('create_missing_relations')}
          help={tcap('help.create_missing_relations')}
          type="checkbox"
          riot-value={valueWithDefaults('create_missing_relations')}
          ref="fields"
        />

        <kor-input
          name="mirador_page_template"
          label={nameFor('mirador_page_template')}
          riot-value={valueWithDefaults('mirador_page_template')}
          ref="fields"
        />

        <kor-input
          name="mirador_manifest_template"
          label={nameFor('mirador_manifest_template')}
          riot-value={valueWithDefaults('mirador_manifest_template')}
          ref="fields"
        />

        <h2>{tcap('settings.help')}</h2>
        <div class="hr"></div>

        <kor-input
          name="help_general.en"
          label={nameFor('help_general') + ' - en'}
          type="textarea"
          riot-value={valueWithDefaults('help_general.en')}
          ref="fields"
        />
        <kor-input
          name="help_general.de"
          label={nameFor('help_general') + ' - de'}
          type="textarea"
          riot-value={valueWithDefaults('help_general.de')}
          ref="fields"
        />

        <kor-input
          name="help_search.en"
          type="textarea"
          label={nameFor('help_search') + ' - en'}
          riot-value={valueWithDefaults('help_search.en')}
          ref="fields"
        />
        <kor-input
          name="help_search.de"
          type="textarea"
          label={nameFor('help_search') + ' - de'}
          riot-value={valueWithDefaults('help_search.de')}
          ref="fields"
        />

        <kor-input
          name="help_upload.en"
          type="textarea"
          label={nameFor('help_upload') + ' - en'}
          riot-value={valueWithDefaults('help_upload.en')}
          ref="fields"
        />
        <kor-input
          name="help_upload.de"
          type="textarea"
          label={nameFor('help_upload') + ' - de'}
          riot-value={valueWithDefaults('help_upload.de')}
          ref="fields"
        />

        <kor-input
          name="help_login.en"
          type="textarea"
          label={nameFor('help_login') + ' - en'}
          riot-value={valueWithDefaults('help_login.en')}
          ref="fields"
        />
        <kor-input
          name="help_login.de"
          type="textarea"
          label={nameFor('help_login') + ' - de'}
          riot-value={valueWithDefaults('help_login.de')}
          ref="fields"
        />

        <kor-input
          name="help_profile.en"
          type="textarea"
          label={nameFor('help_profile') + ' - en'}
          riot-value={valueWithDefaults('help_profile.en')}
          ref="fields"
        />
        <kor-input
          name="help_profile.de"
          type="textarea"
          label={nameFor('help_profile') + ' - de'}
          riot-value={valueWithDefaults('help_profile.de')}
          ref="fields"
        />

        <kor-input
          name="help_new_entries.en"
          type="textarea"
          label={nameFor('help_new_entries') + ' - en'}
          riot-value={valueWithDefaults('help_entries.en')}
          ref="fields"
        />
        <kor-input
          name="help_new_entries.de"
          type="textarea"
          label={nameFor('help_new_entries') + ' - de'}
          riot-value={valueWithDefaults('help_entries.de')}
          ref="fields"
        />

        <kor-input
          name="help_authority_groups.en"
          type="textarea"
          label={nameFor('help_authority_groups') + ' - en'}
          riot-value={valueWithDefaults('help_authority_groups.en')}
          ref="fields"
        />
        <kor-input
          name="help_authority_groups.de"
          type="textarea"
          label={nameFor('help_authority_groups') + ' - de'}
          riot-value={valueWithDefaults('help_authority_groups.de')}
          ref="fields"
        />

        <kor-input
          name="help_user_groups.en"
          type="textarea"
          label={nameFor('help_user_groups') + ' - en'}
          riot-value={valueWithDefaults('help_user_groups.en')}
          ref="fields"
        />
        <kor-input
          name="help_user_groups.de"
          type="textarea"
          label={nameFor('help_user_groups') + ' - de'}
          riot-value={valueWithDefaults('help_user_groups.de')}
          ref="fields"
        />

        <kor-input
          name="help_clipboard.en"
          type="textarea"
          label={nameFor('help_clipboard') + ' - en'}
          riot-value={valueWithDefaults('help_clipboard.en')}
          ref="fields"
        />
        <kor-input
          name="help_clipboard.de"
          type="textarea"
          label={nameFor('help_clipboard') + ' - de'}
          riot-value={valueWithDefaults('help_clipboard.de')}
          ref="fields"
        />

        <h2>{tcap('settings.other')}</h2>
        <div class="hr"></div>

        <kor-input
          name="sources_release"
          label={nameFor('sources_release')}
          riot-value={valueWithDefaults('sources_release')}
          ref="fields"
        />

        <kor-input
          name="sources_pre_release"
          label={nameFor('sources_pre_release')}
          riot-value={valueWithDefaults('sources_pre_release')}
          ref="fields"
        />

        <kor-input
          name="sources_default"
          label={nameFor('sources_default')}
          riot-value={valueWithDefaults('sources_default')}
          ref="fields"
        />

        <kor-input
          name="repository_uuid"
          label={nameFor('repository_uuid')}
          riot-value={valueWithDefaults('repository_uuid')}
          ref="fields"
        />

        <kor-input type="submit" />
      </form>
    </div>
  </div>

  <div class="clearfix"></div>

  <script type="text/coffee">
    tag = this
    tag.mixin(wApp.mixins.sessionAware)
    tag.mixin(wApp.mixins.i18n)
    tag.mixin(wApp.mixins.page)
    
    tag.errors = {}

    tag.on 'mount', ->
      tag.title(tag.t('activerecord.models.setting', {count: 'other'}))
      fetch()
      fetchGroups()
      fetchRelations()

    tag.valueWithDefaults = (key) ->
      tag.values[key]

    tag.nameFor = (key) ->
      tag.tcap("settings.values.#{key}")

    tag.newMediaLabels = () ->
      return [
        {value: 'pages.new_media', label: tag.tcap('pages.new_media')},
        {value: 'pages.new_entries', label: tag.tcap('pages.new_entries')}
      ]

    tag.submit = (event) ->
      event.preventDefault()
      p = update()
      p.done (data) ->
        tag.errors = {}
      p.fail (xhr) ->
        tag.errors = JSON.parse(xhr.responseText).errors
      p.always ->
        tag.update()
        wApp.utils.scrollToTop()

    update = ->
      Zepto.ajax(
        type: 'PATCH'
        url: "/settings"
        data: JSON.stringify(
          settings: values()
          mtime: tag.mtime
        )
        success: (data) ->
          wApp.bus.trigger('config-updated')
          fetch()
      )

    values = ->
      # TODO: add lock version functionality to all forms
      result = {}
      for field in tag.refs['fields']
        result[field.name()] = field.value()
      result

    fetch = ->
      Zepto.ajax(
        url: "/settings"
        success: (data) ->
          tag.values = data.values
          tag.defaults = data.defaults
          tag.mtime = data.mtime
          tag.update()
      )

    fetchGroups = ->
      Zepto.ajax(
        url: "/credentials"
        success: (data) ->
          tag.groups = data.records
          tag.update()
        error: ->
          wApp.bus.trigger('access-denied')
      )

    fetchRelations = ->
      Zepto.ajax(
        url: "/relations/names"
        success: (data) ->
          tag.relations = data
          tag.update()
      )

  </script>

</kor-settings-editor>