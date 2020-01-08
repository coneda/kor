json.message @message

if @id
  json.id @id
end

if @errors
  json.errors @errors
end

if @record
  json.id @record.id
end

if @opts
  json.no_messaging @opts[:no_messaging]
end

if @code
  json.code @code
end
