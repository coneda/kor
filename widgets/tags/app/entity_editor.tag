<kor-entity-editor>

  <h1>Entity Editor</h1>

  <div class="hr"></div>

  <form>
    <kor-field
      field-id="name"
      label-key="entity.name"
      model={opts.entity}
      errors={errors.name}
    />

    <kor-field
      field-id="distinct_name"
      label-key="entity.distinct_name"
      model={opts.entity}
      errors={errors.distinct_name}
    />

    <kor-field
      field-id="distinct_name"
      label-key="entity.distinct_name"
      model={opts.entity}
      errors={errors.distinct_name}
    />
  </form>

  <script type="text/coffee">
    tag = this
  </script>

</kor-entity-editor>