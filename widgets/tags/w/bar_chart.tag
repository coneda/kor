<w-bar-chart>

  <svg riot-width={width()} riot-height={height()}>
    <rect
      class="bg"
      riot-width={width()}
      riot-height={height()}
    />
    <g each={value, i in sortedItems()}>
      <rect
        class="bar"
        x="0"
        riot-y={yFor(i)}
        height="30"
        riot-width="{widthPercentFor(value)}%"
      />
      <text x="5" riot-y={yForText(i)} class="label">
        {value.label} ({value.value})
      </text>
    </g>
  </svg>

  <script type="text/coffee">
    tag = this
    tag.opts.items ||= []

    max = 0
    tag.max = ->
      max ||= if opts.items.length > 0
        Math.max((v.value for v in opts.items)...)
      else
        0
    tag.width = -> tag.opts.width || "100%"
    tag.height = -> Math.max(tag.opts.items.length * 35 - 5, 0)
    tag.widthPercentFor = (value) -> value.value / tag.max() * 100
    tag.sortedItems = -> tag.opts.items.sort (a, b) -> b.value - a.value

    tag.yFor = (i) -> i * (30 + 5);
    tag.yForText = (i) -> 20 + i * (30 + 5);
  </script>

</w-bar-chart>