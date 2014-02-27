# Description:
#   Drupal style factoid support for your hubot.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   <factoid> is <some phrase, link, whatever> - Creates a factoid
#   <factoid> is also <some phrase, link, whatever> - Updates a factoid.
#   <factoid>? - Prints the factoid, if it exists.
#   <factoid>! - Prints the factoid, if it exists.
#   hubot: tell <user> about <factoid> - Tells the user about a factoid, if it exists
#   hubot no, <factoid> is <some phrase, link, whatever> - Replaces the full definition of a factoid
#   hubot factoids list - List all factoids
#   hubot factoid delete <factoid> - delete a factoid
#
# Author:
#   q0rban

class Factoids
  constructor: (@robot) ->
    @robot.brain.on 'loaded', =>
      @cache = @robot.brain.data.factoids
      @cache = {} unless @cache

  add: (key, verb, val) ->
    if existing = @get key
      "#{key} #{existing.verb} already #{existing.factoid}"
    else
      this.setFactoid key, verb, val

  append: (key, verb, val) ->
    if existing = @get key
      existing.factoid += " and #{verb} also #{val}"
      @cache[key] = existing
      @robot.brain.data.factoids = @cache
      "Ok. #{key} #{verb} also #{val} "
    else
      "No factoid for #{key}."

  setFactoid: (key, verb, val) ->
    @cache[key] = {
      "key": key,
      "verb": verb,
      "factoid": val
    }
    @robot.brain.data.factoids = @cache
    "OK. #{key} #{verb} #{val}."

  delFactoid: (key) ->
    delete @cache[key]
    @robot.brain.data.factoids = @cache
    "OK. I forgot about #{key}."

  niceGet: (key) ->
    @cache[key] or "No factoid for #{key}"

  get: (key) ->
    @cache[key]

  list: ->
    Object.keys(@cache)

  handleFactoid: (key, verb, factoid) ->
    if match = /^also (.+)/i.exec factoid
      @append key, verb, match[1]
    else if match = /^no,? (.+)/i.exec key
      @setFactoid match[1], verb, factoid
    else if not /^(forget about|factoids? delete)/i.exec key
      @add key, verb, factoid

module.exports = (robot) ->
  factoids = new Factoids robot

  robot.hear /(.+)[\?!]$/i, (msg) ->
    if record = factoids.get msg.match[1]
      factoid = record.factoid.replace /!who/ig, msg.message.user.name
      if match = /^\ *<reply>(.*)/i.exec factoid
        msg.send match[1]
      else
        msg.send "#{record.key} #{record.verb} #{factoid}"

  robot.respond /tell (.+) about (.+)/i, (msg) ->
    if record = factoids.get msg.match[2]
      record.factoid.replace '!who', msg.message.user.name
      msg.send "#{msg.match[1]}: #{record.key} #{record.verb} #{record.factoid}"

  robot.respond /(.+?) (is|are) (.+)/i, (msg) ->
    msg.reply factoids.handleFactoid msg.match[1], msg.match[2], msg.match[3]

  robot.respond /factoids? list/i, (msg) ->
    msg.send factoids.list().join('\n')

  robot.respond /(forget about|factoids? delete) (.+)\.?$/i, (msg) ->
    msg.reply factoids.delFactoid msg.match[2]
