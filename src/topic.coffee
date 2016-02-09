{EventEmitter} = require 'events'

class Topic extends EventEmitter
  constructor: (@client, { key, topic_key, created_by, @body, html_body }) ->
    @key = topic_key || key
    @htmlBody = html_body

module.exports = Topic
