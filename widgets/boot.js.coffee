$(document).ready ->
  console.log(this)
  $('body').append('<div data-is="w-style" style="display: none">')
  riot.mount('*')