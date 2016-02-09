{EventEmitter} = require 'events'

class Notification extends EventEmitter
  constructor: (@client, {@name, team_name, timezone_offset, profile_photo, @locale}) ->
    @teamName = team_name
    @timezoneOffset = timezone_offset
    @profilePhoto = profile_photo

  subscribe: ->
    channelName = "presence-team-#{@teamName}"
    @client.subscribeChannel channelName, (err, channel) =>
      @pusherChannel = channel

module.exports = Team
