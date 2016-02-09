{EventEmitter} = require 'events'

class Group extends EventEmitter
  constructor: (@client, @groupName, { group_name, @name }) ->
    @groupName ||= group_name

module.exports = Group
