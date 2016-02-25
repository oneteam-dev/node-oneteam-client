{PusherClient} = require 'pusher-node-client'
{EventEmitter} = require 'events'
Team = require './team'
crypto = require 'crypto'
request = require 'request'

class Client extends EventEmitter

  constructor: ({ @accessToken, @clientSecret, @clientKey, @pusherKey, @baseURL }) ->
    @baseURL ?= process.env.ONETEAM_BASE_API_URL or 'https://api.one-team.io'
    @pusherKey ?= process.env.ONETEAM_PUSHER_KEY or 'd62fcfd64facee71a178'
    @connected = no
    @accessToken ?= null
    @clientKey ?= null
    @clientSecret ?= null
    @pusherClient = null

  connect: (callback) ->
    return callbaack() if @connected
    @pusherClient = new PusherClient
      key: @pusherKey
      authEndpoint: "#{@baseURL}/pusher/auth"
    @pusherClient.on 'connect', =>
      @connected = yes
      @emit 'connected'
      callback()
    @pusherClient.connect()


  # request(method, class, path, callback)
  # request(method, class, path, data, callback)
  # request(method, path, callback)
  # request(method, path, data, callback)
  request: (method, klass, path, data, callback) ->
    if typeof klass is 'string'
      callback = data
      data = path
      path = klass
      klass = null
    if typeof data is 'function' and not callback
      callback = data
      data = undefined
    fn = =>
      url = "#{@baseURL}#{path}"
      headers = {}
      headers['Authorization'] = "Bearer #{@accessToken}" if @accessToken
      method = method.toUpperCase()
      method = 'DELETE' if method is 'DEL'
      opts = {method, headers}
      if ['POST', 'PUT', 'PATCH'].indexOf(method) isnt -1
        opts.body = data
        opts.json = yes
      request url, opts, (err, req, body) =>
        if typeof body is 'string'
          body = try JSON.parse body
        err ?= @errorResponse body
        if typeof klass is 'function' && !err && (key = body.key)
          body = new klass @, key, body
        callback err, req, body
    if /\/tokens$/.test path
      fn.call @
    else
      @fetchAccessToken fn

  ['get', 'post', 'put', 'patch', 'del'].forEach (m) =>
    @prototype[m] = (args...) -> @request m, args...

  fetchAccessToken: (callback) ->
    if @accessToken
      process.nextTick callback.bind this, null, @accessToken
      return
    unless @clientKey && @clientSecret
      throw new Error 'accessToken or pair of clientKey + clientSecret is must be set.'
    timestamp = @timestamp()
    secret_token = crypto
      .createHmac('sha256', @clientSecret)
      .update("#{@clientKey}:#{timestamp}")
      .digest('hex')
    @post "/clients/#{@clientKey}/tokens", {timestamp, secret_token}, (err, httpResponse, body) =>
      body ?= {}
      {token} = body
      return callback err, null if err ||= @errorResponse body
      @accessToken = token || null
      callback null, @accessToken

  subscribeChannel: (channelName, callback) ->
    @fetchAccessToken (err, accessToken) =>
      return callbaack err, null if err
      @connect =>
        channel = @pusherClient.subscribe channelName, {accessToken}
        channel.on 'success', -> callback null, channel
        channel.on 'pusher:error', (e) -> callback e, null

  errorResponse: (data) ->
    {errors} = data
    if msg = errors?[0].message
      new Error msg

  timestamp: -> Date.now()

  team: (teamName, callback) ->
    @get "/teams/#{teamName}", (err, res, body) =>
      return callback err if err ||= @errorResponse body
      callback null, new Team(@, teamName, body)

  self: (callback) ->
    @get '/clients/self', (err, res, body) =>
      return callback err if err ||= @errorResponse body
      callback null, body

module.exports = Client
