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
    self = this
    self.messages = []
    self.history = []

    self.animend = (event) ->
      i = self.messages.indexOf(event.item.data)
      self.history.push(self.messages[i])
      self.messages.splice(i, 1)
      self.update()

    fading = (data) ->
      self.messages.push(data)
      self.update()

      setTimeout(
        (->
          data.remove = true
          self.update()
        ),
        5000
      )

    kor.bus.on 'notify', (data) ->
      type = data.type || 'default'
      if type == 'default' then fading(data)
      self.update()

  </script>

</kor-notifications>