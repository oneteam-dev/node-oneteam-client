{expect} = require 'chai'
nock = require 'nock'
sinon = require 'sinon'

describe 'client', ->
  client = null
  opts = null
  clock = null
  nockScope = null
  currentTime = 1455008759942
  Client = null

  beforeEach ->
    process.env.ONETEAM_BASE_API_URL = 'https://api.one-team.test'
    Client = require '../src/client'
    client = new Client opts
    clock = sinon.useFakeTimers currentTime
    nockScope = nock 'https://api.one-team.test'
    nock.disableNetConnect()

  afterEach ->
    nock.cleanAll()

  describe 'fetchAccessToken(callback)', ->
    subject = null
    beforeEach ->
      subject = client.fetchAccessToken.bind client
    context 'when required options are not set', ->
      before ->
        opts = {}
      it 'throw an error', ->
        expect(subject).to.throw 'accessToken or pair of clientKey + clientSecret is must be set.'

    context 'when accessToken is set', ->
      before ->
        opts = accessToken: 'asdf'
      it 'callbacks with accessToken', (done) ->
        subject (err, data) ->
          expect(data).to.equal 'asdf'
          do done

    context 'when clientKey and clientSecret is set', (done) ->
      before ->
        opts =
          clientKey: 'fake-key'
          clientSecret: 'fake-secret'

      context 'when request succeeded', ->
        beforeEach ->
          nockScope
            .post '/clients/fake-key/tokens'
            .reply 201, { token: 'qwerty' }

        it 'callbacks with accessToken', (done) ->
          subject (err, data) ->
            expect(err).to.be.null
            expect(client.accessToken).to.equal 'qwerty'
            expect(data).to.equal 'qwerty'
            do done

      context 'when request failed', ->
        beforeEach ->
          nockScope
            .post '/clients/fake-key/tokens'
            .reply 400, { errors: [{message: 'bad req'}] }

        it 'callbacks with accessToken', (done) ->
          subject (err, data) ->
            expect(err.message).to.equal 'bad req'
            expect(client.accessToken).to.be.null
            expect(data).to.be.null
            do done

  describe 'team(teamName, callback)', ->
    subject = null
    beforeEach ->
      subject = client.team.bind client
      nockScope
        .post '/clients/fake-key/tokens'
        .reply 201, { token: 'qwerty' }
    before ->
      opts =
        clientKey: 'fake-key'
        clientSecret: 'fake-secret'
    context 'when request succeeded', ->
      beforeEach ->
        nockScope
          .get '/teams/oneteam'
          .replyWithFile 200, "#{__dirname}/fixtures/team.json"

      it 'callbacks with team instance', (done) ->
        subject 'oneteam', (err, team) ->
          expect(err).to.be.null
          expect(team).not.to.be.null
          expect(team.client).to.equal client
          expect(team.name).to.equal 'Oneteam Inc.'
          do done

