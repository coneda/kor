json.message @message

if @errors
  json.errors @errors
end

if @record
  json.id @record.id
end