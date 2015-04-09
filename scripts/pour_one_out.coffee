module.exports = (robot) ->
  robot.respond /\s*pour\s+one\s+out\s+for\s+(.*)/i, (msg) ->
    msg.shorten 'http://pour-one-out.herokuapp.com/api/v1?' + encodeURIComponent msg.match[1] (img) ->
      msg.send img
