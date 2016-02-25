{EventEmitter} = require 'events'
{expect} = require 'chai'
nock = require 'nock'
sinon = require 'sinon'

describe 'topic', ->
  client = null
  clock = null
  nockScope = null
  currentTime = 1455008759942
  Topic = null
  Client = null
  topic = null

  beforeEach ->
    process.env.ONETEAM_BASE_API_URL = 'https://api.one-team.test'
    Client = require '../src/client'
    Topic = require '../src/topic'
    client = new Client accessToken: 'dummy'
    clock = sinon.useFakeTimers currentTime
    nockScope = nock 'https://api.one-team.test'
    nock.disableNetConnect()
    topic = new Topic client, 'poiuyt',
      title: 'Hello World'
      body: 'Yo'
      html_body: '<p>Yo</p>'

  describe 'constructor', ->
    it 'retains options in argument', ->
      expect(topic.title).to.equal 'Hello World'
      expect(topic.body).to.equal 'Yo'
      expect(topic.htmlBody).to.equal '<p>Yo</p>'
      expect(topic.key).to.equal 'poiuyt'

  describe 'createMessage', ->
    beforeEach ->
      nockScope
        .post '/topics/poiuyt/messages'
        .reply 201,
          key: 'asdfe1234'
          body: 'YO'
          html_body: '<p>YO</p>'

    it 'sends request', (done) ->
      topic.createMessage 'hello', (err, res, message) ->
        return done err if err
        expect(message.body).to.equal 'YO'
        expect(message.htmlBody).to.equal '<p>YO</p>'
        expect(message.key).to.equal 'asdfe1234'
        do done


