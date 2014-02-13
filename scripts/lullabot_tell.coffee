# Description:
#   Tell Hubot to send a user a message when present in the room.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot tell <username> <some message> - tell <username> <some message> next time they are present.
#
# Author:
#   q0rban

class Tell
  constructor: (@robot) ->
    @robot.brain.on 'loaded', =>
      @cache = @robot.brain.data.tell
      @cache = {} unless @cache

  save: (author, username, room, message) ->
    record = {
      "author": author,
      "time": new Date(),
      "room": room,
      "message": message
    }
    @cache[username] = new Array() unless @cache[username]
    @cache[username].push record
    @robot.brain.data.tell = @cache

  check: (username) ->
    @cache[username].length

  get: (username) ->
    if this.check username
      @cache[username]

  clear: (username) ->
    @cache[username] = null
    @robot.brain.data.tell = @cache


module.exports = (robot) ->
  tell = new Tell robot

  robot.respond /tell ([\w.-]*):? (.*)/i, (msg) ->
    # Assume we have lullabot_factoid installed, and do nothing if the message
    # has 'about' in it.
    if /^about/i.exec msg.match[2]
      return
    author = msg.message.user.name
    username = msg.match[1]
    room = msg.message.user.room
    message = msg.match[2]
    tell.save author, username, room, message
    msg.send "Ok, I'll tell #{username} you said '#{msg.match[2]}'."
    return

  # When a user enters, check if someone left them a message.
  robot.enter (msg) ->
    username = msg.message.user.name
    count = tell.check username
    if count > 1
      msg.send "I've got #{count} messages for you, #{username}."
    if count == 1
      msg.send "I've got a message for you, #{username}."

  # When a user says something, tell them their messages if they have any.
  robot.hear /.*/, (msg) ->
    username = msg.message.user.name
    if messages = tell.get username
      for record in messages
        time = record.time.toLocaleString()
        msg.send "#{username}, #{record.author} asked me to tell you '#{record.message}'. (#{time} in #{record.room})"
      tell.clear username
