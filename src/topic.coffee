{EventEmitter} = require 'events'

class Topic extends EventEmitter
  constructor: (@client, @key, { key, topic_key, created_by, @body, html_body }) ->
    @key ||= topic_key || key
    @htmlBody = html_body

  subscribe: ->
    channelName = "private-topic-#{@key}"
    @client.subscribeChannel channelName, (err, channel) =>
      bindEvent = (eventName, DataClass) =>
        channel.on "comuque:#{eventName}", (data) =>
          @emit eventName.replace('-', ':'), new DataClass(@, data.key, data)
      bindEvent 'topic-created', Topic
      bindEvent 'topic-updated', Topic
      bindEvent 'topic-deleted', Topic
      @pusherChannel = channel

module.exports = Topic
