To create a new bot, add a file in here with the name of your bot. The contents
of this file will be the environment variables you need for your bot. For example:

```bash
export HUBOT_IRC_ROOMS="#q0rban"
export HUBOT_IRC_SERVER="irc.freenode.net"
export HUBOT_IRC_NICK="q0rbot"
# This will be created by default from your bot's name, but if you want a custom
# key, feel free to specify it here.
#export REDIS_KEY="hubot:q0rbot:storage"
```
