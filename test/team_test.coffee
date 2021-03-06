{EventEmitter} = require 'events'
{expect} = require 'chai'
nock = require 'nock'
sinon = require 'sinon'

describe 'team', ->
  client = null
  clock = null
  nockScope = null
  currentTime = 1455008759942
  Team = null
  Client = null
  team = null

  beforeEach ->
    process.env.ONETEAM_BASE_API_URL = 'https://api.one-team.test'
    Client = require '../src/client'
    Team = require '../src/team'
    client = new Client accessToken: 'dummy'
    clock = sinon.useFakeTimers currentTime
    nockScope = nock 'https://api.one-team.test'
    nock.disableNetConnect()
    team = new Team client, 'oneteam',
      name: 'Oneteam Inc.'
      timezone_offset: 9
      profile_photo: { url: 'hoge' }
      locale: 'ja'

  afterEach ->
    nock.cleanAll()

  describe 'constructor', ->
    it 'retains options in argument', ->
      expect(team.name).to.equal 'Oneteam Inc.'
      expect(team.teamName).to.equal 'oneteam'
      expect(team.timezoneOffset).to.equal 9
      expect(team.profilePhoto).to.deep.equal { url: 'hoge' }
      expect(team.locale).to.equal 'ja'

  describe 'createTopic', ->
    beforeEach ->
      nockScope
        .post '/teams/oneteam/topics'
        .reply 201,
          title: 'qwerty'
          key: 'asdfe1234'
          body: 'YO'
          html_body: '<p>YO</p>'

    it 'sends request', (done) ->
      team.createTopic { title: 'foo', body: 'hello' }, (err, res, topic) ->
        return done err if err
        expect(topic.title).to.equal 'qwerty'
        do done

