# Description:
#   Utility commands surrounding Hubot uptime.
#
# Commands:
#   hubot ping - Reply with pong

module.exports = (robot) ->
  robot.respond /PING$/i, (msg) ->
    msg.send "pong"
