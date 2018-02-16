json.partial! 'customized', {
  user: @user,
  additions: params[:include]
}
