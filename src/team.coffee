{EventEmitter} = require 'events'
Topic = require './topic'

class Team extends EventEmitter
  constructor: (@client, @teamName, {@name, team_name, timezone_offset, profile_photo, @locale}) ->
    @teamName ||= team_name
    @timezoneOffset = timezone_offset
    @profilePhoto = profile_photo

  subscribe: ->
    channelName = "presence-team-#{@teamName}"
    @client.subscribeChannel channelName, (err, channel) =>
      bindEvent = (eventName, DataClass) =>
        channel.on "comuque:#{eventName}", (data) =>
          @emit eventName.replace('-', ':'), new DataClass(@, data)
      bindEvent 'message-created', Message
      bindEvent 'message-updated', Message
      bindEvent 'message-deleted', Message
      @pusherChannel = channel

module.exports = Team
