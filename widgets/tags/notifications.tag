<kor-notifications>

  <ul>
    <li each={data in messages}>{data.message}</li>
  </ul>

  <script type="text/coffee">
    self = this
    self.messages = []
    self.history = []

    fading = (data) ->
      self.messages.push(data)
      setTimeout(
        (->
          i = self.messages.indexOf(data)
          self.history.push(self.messages[i])
          self.messages.splice(i, 1)
          self.update()
        ),
        2000
      )

    kor.bus.on 'notify', (data) ->
      type = data.type || 'default'
      if type == 'default' then fading(data)
      self.update()

  </script>

</kor-notifications>