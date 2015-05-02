kor.service "kor_tools", [
  ->
    service = {
      in_groups_of: (array, per_row = 4, fill = true) ->
        result = []
        current = []
        for i in array
          if current.length == per_row
            result.push(current)
            current = []
          current.push(i)

        if current.length > 0
          if fill
            while current.length < per_row
              current.push({})

          result.push(current)

        result
    }
]