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

module.exports = (robot) ->

  _ = require 'underscore'

  robot.hear /^all: ?(.*)/i, (msg) ->
    announcer = msg.message.user.name
    console.log robot.brain.data.users
    users = _.reject((_.values _.pluck robot.brain.data.users, 'name'), (name) -> name == announcer)
    msg.send if users.length then users.join(', ') + ": #{announcer} said #{msg.match[1]}"
