module.exports = (robot) ->
  robot.respond /(?:mo?u)?sta(?:s|c)h(?:e|ify)?(?: me)? (.*)/i, (msg) ->
    msg.imageSearch msg.match[1], false, true, (img) ->
      url = 'https://mustachify.me/rand?src=' + encodeURIComponent(img)
      msg.shorten url, msg.send
