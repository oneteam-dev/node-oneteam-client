{EventEmitter} = require 'events'

class Message extends EventEmitter
  constructor: (@client, @key, { @body, html_body, created_at, topic }) ->
    @htmlBody = html_body
    @createdAt = new Date created_at
    @topicKey = topic?.key

  topic: (callback) ->
    @client.get "/topics/#{@topicKey}", callback

module.exports = Message
