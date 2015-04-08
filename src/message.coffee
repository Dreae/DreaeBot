querystring = require 'querystring'
request = require 'request'

class Message
  constructor: (@robot, @stanza) ->
    @body = (() =>
      for child in @stanza.children
        if child.nodeName == 'body' or child.nodeName == 'html'
          return child.children.join(' ')
      return ''
    )()

    @send = @robot.send
    @send_img = @robot.send_img
    @send_img_html = @robot.send_img_html

  imageSearch: (query, animate, face, callback) =>
    qs = {
      v: '1.0',
      q: query,
      rsz: 8,
      safe: 'active'
    }
    if animate
      qs.imgtype = 'animated'
    if face
      qs.imgtype = 'face'
    request('https://ajax.googleapis.com/ajax/services/search/images?' + querystring.stringify(qs), (error, response, body) =>
      if !error && response.statusCode == 200
        data = JSON.parse(body).responseData
        img = @random data.results
        if typeof img == 'undefined'
          return
        callback img.unescapedUrl
        return
    );

  random: (array) =>
    return array[Math.floor(Math.random() * array.length)]

  shorten: (url, callback) =>
    request 'http://tinyurl.com/api-create.php?url=' + encodeURIComponent(url), (error, response, body) =>
      if !error and response.statusCode == 200
        callback body
      else
        console.log error


module.exports = Message
