var amqp = require('amqp');
var io = require('socket.io').listen(3001);
var connection = amqp.createConnection({ host: 'localhost' });


// Wait for connection to become established.
connection.on('ready', function(){
  console.log("rabbit is up and running...");

  io.sockets.on('connection', function(socket){  
    connection.queue("image_upload", function(q){
      q.bind('#');

      q.subscribe(function (message) {
        console.log("image")
        io.sockets.emit('image_upload', message.data.toString())
      });
    });
  });
});
