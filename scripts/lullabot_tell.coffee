# Description:
#   Tell Hubot to send a user a message when present in the room
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot tell <username> <some message> - tell <username> <some message> next time they are present. Case-Insensitive prefix matching is employed when matching usernames, so "foo" also matches "Foo" and "foooo"
#
# Author:
#   christianchristensen, lorenzhs, xhochy

class Tell
  constructor: (@robot) ->
    @robot.brain.on 'loaded', =>
      @cache = @robot.brain.data.tell
      @cache = {} unless @cache

  append: (key, val) ->
    if @cache[key]
      @cache[key] = @cache[key] + ", " + val
      @robot.brain.data.factoids = @cache
      "Ok. #{key} is also #{val} "
    else
      "No factoid for #{key}. It can't also be #{val} if it isn't already something."

  save: (username, room, message) ->
    time = new Date().toLocaleString()
    record = {
      "time": time,
      "username": username,
      "room": room,
      "message": message
    }
    @cache[username] = Array unless @cache[username]
    @cache[username].push record
    console.log @cache
    @robot.brain.data.tell = @cache

module.exports = (robot) ->
   tell = new Tell robot
   robot.respond /tell ([\w.-]*):? (.*)/i, (msg) ->
     # Assume we have lullabot_factoid installed, and do nothing if the message
     # has 'about' in it.
     if /^about/i.exec msg.match[2]
       console.log 'doh'
       return
     username = msg.match[1]
     room = msg.message.user.room
     message = msg.match[2]
     tell.save username, room, message
     msg.send "Ok, I'll tell #{username} you said '#{msg.match[2]}'."
     return

   # When a user enters, check if someone left them a message
   robot.enter (msg) ->
     username = msg.message.user.name
     room = msg.message.user.room
     if localstorage[room]?
       for recipient, message of localstorage[room]
         # Check if the recipient matches username
         if username.match(new RegExp "^"+recipient, "i")
           tellmessage = username + ": " + localstorage[room][recipient]
           delete localstorage[room][recipient]
           msg.send tellmessage
     return
