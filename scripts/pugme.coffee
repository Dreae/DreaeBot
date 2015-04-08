request = require 'request'

module.exports = (robot) ->
	robot.respond /\s*pug\s+me/i, (msg) ->
		request 'https://pugme.herokuapp.com/random', (error, response, body) ->
			if !error and response.statusCode == 200
				pug = JSON.parse(body).pug
				if typeof pug != 'undefined'
					msg.shorten pug, (img) ->
						msg.send img
