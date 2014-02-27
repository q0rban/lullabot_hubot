# Description
#   Allows you to highlight everyone in the room with a message.
#
# Dependencies:
#   "underscore": "1.3.3"
#
# Configuration:
#   None
#
# Commands:
#   all: <message> - Sends your message and mentions everyone curently in the chat room.
#
# Author:
#   q0rban
_ = require 'underscore'

module.exports = (robot) ->
  robot.hear /^all: ?(.*)/i, (msg) ->
    announcer = msg.message.user.name
    room = msg.message.user.room
    names = _.keys robot.adapter.bot.chans[room].users
    users = _.reject(names, (name) ->
      name is announcer or name is robot.name
    )
    msg.send if users.length then users.join(', ') + ": #{announcer} said #{msg.match[1]}"
