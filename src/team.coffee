{EventEmitter} = require 'events'

class Team extends EventEmitter
  constructor: (@client, {@name, team_name, timezone_offset, profile_photo, @locale}) ->
    @teamName = team_name
    @timezoneOffset = timezone_offset
    @profilePhoto = profile_photo

module.exports = Team
