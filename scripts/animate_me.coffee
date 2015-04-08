module.exports = (robot) ->
  robot.respond /animate\s+me\s+(.+)/i, (msg) ->
    msg.imageSearch msg.match[1], true, false, (img) ->
      msg.shorten img, msg.send
