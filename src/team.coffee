{EventEmitter} = require 'events'
Topic = require './topic'
Message = require './message'
Group = require './group'

class Team extends EventEmitter
  constructor: (@client, @teamName, {@name, team_name, timezone_offset, profile_photo, @locale}) ->
    @teamName ||= team_name
    @timezoneOffset = timezone_offset
    @profilePhoto = profile_photo

  path: () -> "/teams/#{@teamName}"

  createTopic: (topic, callback) ->
    {title, body} = topic
    @client.post Topic, "#{@path()}/topics", topic, callback

  subscribe: ->
    channelName = "presence-team-#{@teamName}"
    @client.subscribeChannel channelName, (err, channel) =>
      bindEvent = (eventName, DataClass) =>
        channel.on "comuque:#{eventName}", (data) =>
          @emit eventName.replace('-', ':'), new DataClass(@client, data.key, data)
      bindEvent 'topic-created', Topic
      bindEvent 'topic-updated', Topic
      bindEvent 'topic-deleted', Topic
      bindEvent 'message-created', Message
      bindEvent 'message-updated', Message
      bindEvent 'message-deleted', Message
      @pusherChannel = channel

module.exports = Team
