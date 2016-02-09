{EventEmitter} = require 'events'

class Message extends EventEmitter
  constructor: (@client, @key, { @body, html_body, created_at }) ->
    @htmlBody = html_body
    @createdAt = new Date created_at

module.exports = Message
