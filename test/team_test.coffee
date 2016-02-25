{EventEmitter} = require 'events'
{expect} = require 'chai'
nock = require 'nock'
sinon = require 'sinon'

describe 'team', ->
  client = null
  opts = null
  clock = null
  nockScope = null
  currentTime = 1455008759942

  beforeEach ->
    process.env.ONETEAM_BASE_API_URL = 'https://api.one-team.test'
    client = new Client opts
    clock = sinon.useFakeTimers currentTime
    nockScope = nock 'https://api.one-team.test'
    nock.disableNetConnect()

  afterEach ->
    nock.cleanAll()

