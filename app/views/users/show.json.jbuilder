json.partial! 'customized', {
  user: @record,
  additions: params[:include]
}