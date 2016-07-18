var express = require('express');
var app = express();
var bodyParser = require('body-parser');

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

var port = process.env.PORT || ###NAGIOS_API_PORT###;

var routes = require('./routes.js')(app);

app.listen(port);
console.log('Listening on port %s...', port);