request = require 'request'
querystring = require 'querystring'
util = require 'util'

module.exports = (robot) ->
  robot.hear /\s*(?:https|http):\/\/(?:www\.)?(?:youtube\.com\/watch\?\S*v=(\S+)|youtu\.be\/([^\?]+))/i, (msg) ->
    vid_id = if msg.match[1] then msg.match[1] else msg.match[2]
    params = {'id': vid_id, 'part': 'snippet', 'key': process.env.GOOGLE_API_KEY};
    request 'https://content.googleapis.com/youtube/v3/videos?' + querystring.stringify(params), (error, response, body) ->
      if !error && response.statusCode == 200
        res_json = JSON.parse(body)['items'][0]
        vid_info = util.format('Youtube: %s - %s', res_json['snippet']['channelTitle'], res_json['snippet']['title'])
        msg.send vid_info
      else
        console.error(response.statusCode)
