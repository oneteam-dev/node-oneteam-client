{EventEmitter} = require 'events'
Message = require './message'

class Topic extends EventEmitter
  constructor: (@client, @key, { key, topic_key, created_by, @title, @body, html_body }) ->
    @key ||= topic_key || key
    @htmlBody = html_body

  path: () -> "/topics/#{@key}"

  createMessage: (body, callback) ->
    @client.post Message, "#{@path()}/messages", {body}, callback

  del: (callback) ->
    @client.del @path(), callback

  subscribe: ->
    channelName = "private-topic-#{@key}"
    @client.subscribeChannel channelName, (err, channel) =>
      bindEvent = (eventName, DataClass) =>
        channel.on "comuque:#{eventName}", (data) =>
          @emit eventName.replace('-', ':'), new DataClass(@, data.key, data)
      bindEvent 'message-created', Message
      bindEvent 'message-updated', Message
      bindEvent 'message-deleted', Message
      @pusherChannel = channel

module.exports = Topic
