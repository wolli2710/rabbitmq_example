# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

socket = io.connect('http://localhost:3001');

socket.on "image_upload", (data) ->
    $('#images').prepend(data)