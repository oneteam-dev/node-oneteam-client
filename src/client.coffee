{PusherClient} = require 'pusher-node-client'
{EventEmitter} = require 'events'
Team = require './team'
crypto = require 'crypto'
request = require 'request'

class Client extends EventEmitter

  baseURL: 'https://api.one-team.io'
  pusherKey: 'd62fcfd64facee71a178'

  constructor: ({ @accessToken, @clientSecret, @clientKey }) ->
    @connected = no
    @accessToken ||= null
    @clientKey ||= null
    @clientSecret ||= null
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

  request: (method, path, data, callback) ->
    fn = =>
      if typeof data is 'function' and not callback
        callback = data
        data = undefined
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
        callback err, req, body
    if /\/access_tokens$/.test path
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
    @post "/clients/#{@clientKey}/access_tokens", {timestamp, secret_token}, (err, httpResponse, body) =>
      {access_token} = body
      return callback err, null if err ||= @errorResponse body
      @accessToken = access_token || null
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

  timestamp: -> Math.ceil Date.now() / 1000

  team: (teamName, callback) ->
    @get "/teams/#{teamName}", (err, res, body) =>
      return callback err if err ||= @errorResponse body
      callback null, new Team(@, body)

module.exports = Client
