<kor-notifications>

  <ul>
    <li
      each={data in messages}
      class="bg-warning {kor-fade-animation: data.remove}"
      onanimationend={parent.animend}
    >
      <i class="glyphicon glyphicon-exclamation-sign"></i>
      {data.message}
    </li>
  </ul>

  <script type="text/coffee">
    tag = this
    tag.messages = []
    tag.history = []

    tag.animend = (event) ->
      i = tag.messages.indexOf(event.item.data)
      tag.history.push(tag.messages[i])
      tag.messages.splice(i, 1)
      tag.update()

    fading = (data) ->
      tag.messages.push(data)
      tag.update()

      setTimeout(
        (->
          data.remove = true
          tag.update()
        ),
        5000
      )

    kor.bus.on 'notify', (data) ->
      type = data.type || 'default'
      if type == 'default' then fading(data)
      tag.update()

  </script>

</kor-notifications>