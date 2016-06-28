<kor-notifications>

  <ul>
    <li
      each={data in messages}
      class="bg-warning"
      onanimationend={alert(data)}
    >
      <i class="glyphicon glyphicon-exclamation-sign"></i>
      {data.message}
    </li>
  </ul>

  <style type="text/scss">
    kor-notifications {
      ul {
        perspective: 1000px;
        position: absolute;
        top: 0px;
        right: 0px;

        li {
          padding: 1rem;
          list-style-type: none;
        }
      }
    }
  </style>

  <script type="text/coffee">
    self = this
    self.messages = []
    self.history = []

    self.animend = -> console.log arguments

    fading = (data) ->
      self.messages.push(data)
      self.update()

      li = $(self.root).find('li').last()

      setTimeout(
        (->
          li.addClass 'kor-fade-animation'

          # $(li).one 'animationend', (event) ->
          #   console.log 'ae'
          #   i = self.messages.indexOf(data)
          #   self.history.push(self.messages[i])
          #   self.messages.splice(i, 1)
          #   self.update()
        ),
        2000
      )

      # setTimeout(
      #   (->
      #     i = self.messages.indexOf(data)
      #     self.history.push(self.messages[i])
      #     self.messages.splice(i, 1)
      #     self.update()
      #   ),
      #   2900 
      # )

    kor.bus.on 'notify', (data) ->
      type = data.type || 'default'
      if type == 'default' then fading(data)
      self.update()

  </script>

</kor-notifications>