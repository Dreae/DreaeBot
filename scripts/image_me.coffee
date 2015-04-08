module.exports = (robot) ->
  robot.respond /image\s+me\s+(.+)/i, (msg) ->
    msg.imageSearch msg.match[1], false, false, (img) ->
      msg.shorten img, msg.send
