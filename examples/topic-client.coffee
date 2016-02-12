Client = require '../src/client'

process.on 'uncaughtException', (e) ->
  console.error e

client = new Client if process.env.ACCESS_TOKEN
    accessToken: process.env.ACCESS_TOKEN
  else
    clientKey: process.env.CLIENT_KEY
    clientSecret: process.env.CLIENT_SECRET

client.team process.env.TEAM_NAME, (err, t) ->
  console.info t, err, client
  t.on 'topic:created', (t) ->
    console.info t
  t.subscribe()

console.info client
