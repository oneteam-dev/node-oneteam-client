{EventEmitter} = require 'events'
Topic = require './topic'

class Team extends EventEmitter
  constructor: (@client, {@name, team_name, timezone_offset, profile_photo, @locale}) ->
    @teamName = team_name
    @timezoneOffset = timezone_offset
    @profilePhoto = profile_photo

  subscribe: ->
    channelName = "presence-team-#{@teamName}"
    @client.subscribeChannel channelName, (err, channel) =>
      bindEvent = (eventName, DataClass) =>
        channel.on "comuque:#{eventName}", (data) =>
          @emit eventName.replace('-', ':'), new DataClass(@, data)
      bindEvent 'topic-created', Topic
      bindEvent 'topic-updated', Topic
      bindEvent 'topic-deleted', Topic
      @pusherChannel = channel

module.exports = Team
