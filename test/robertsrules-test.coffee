Helper = require('hubot-test-helper')
chai = require 'chai'

expect = chai.expect

helper = new Helper('../src/robertsrules.coffee')

testQPlusCmd = (cmd) ->
  return ->
    @room.user.say('alice', '@hubot start meeting').then =>
      @room.user.say('alice', cmd).then =>
        @room.user.say('alice', cmd + ' bob').then =>
          expect(@room.messages).to.eql [
            ['alice', '@hubot start meeting']
            ['hubot', 'I have prepared the meeting.']
            ['alice', cmd]
            ['hubot', 'I see alice on the speaker list']
            ['alice', cmd + ' bob']
            ['hubot', 'I see alice, bob on the speaker list']
          ]

testQMinusCmd = (cmd) ->
  return ->
    @room.user.say('alice', '@hubot start meeting').then =>
      # <>
      @room.user.say('alice', 'q+').then =>
        # <alice>
        @room.user.say('alice', cmd).then =>
          # <>
          @room.user.say('alice', 'q+').then =>
            # <alice>
            @room.user.say('alice', 'q+ bob').then =>
              # <alice, bob>
              @room.user.say('alice', cmd + ' bob').then =>
                # <alice>
                @room.user.say('alice', 'q+ bob').then =>
                  # <alice, bob>
                  @room.user.say('alice', cmd).then =>
                    # <bob>
                    expect(@room.messages).to.eql [
                      ['alice', '@hubot start meeting']
                      ['hubot', 'I have prepared the meeting.']
                      ['alice', 'q+']
                      ['hubot', 'I see alice on the speaker list']
                      ['alice', cmd]
                      ['hubot', 'I see no one on the speaker list']
                      ['alice', 'q+']
                      ['hubot', 'I see alice on the speaker list']
                      ['alice', 'q+ bob']
                      ['hubot', 'I see alice, bob on the speaker list']
                      ['alice', cmd + ' bob']
                      ['hubot', 'I see alice on the speaker list']
                      ['alice', 'q+ bob']
                      ['hubot', 'I see alice, bob on the speaker list']
                      ['alice', cmd]
                      ['hubot', 'I see bob on the speaker list']
                    ]

testQueueQuery = (cmd) ->
  return ->
    @room.user.say('alice', '@hubot start meeting').then =>
      @room.user.say('alice', 'q+').then =>
        @room.user.say('alice', cmd).then =>
          expect(@room.messages).to.eql [
            ['alice', '@hubot start meeting']
            ['hubot', 'I have prepared the meeting.']
            ['alice', 'q+']
            ['hubot', 'I see alice on the speaker list']
            ['alice', cmd]
            ['hubot', 'I see alice on the speaker list']
          ]

testAck = (cmd) ->
  return ->
    @room.user.say('alice', '@hubot start meeting').then =>
      @room.user.say('alice', 'q+').then =>
        @room.user.say('alice', cmd + ' alice').then =>
          expect(@room.messages).to.eql [
            ['alice', '@hubot start meeting']
            ['hubot', 'I have prepared the meeting.']
            ['alice', 'q+']
            ['hubot', 'I see alice on the speaker list']
            ['alice', cmd + ' alice']
            ['hubot', 'I see no one on the speaker list']
          ]

describe 'robertsrules', ->
  beforeEach ->
    # TODO start the meeting here
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()

  it 'can start and end the meeting', ->
    @room.user.say('alice', '@hubot start meeting').then =>
      expect(@room.messages).to.eql [
        ['alice', '@hubot start meeting']
        ['hubot', 'I have prepared the meeting.']
      ]
      @room.user.say('alice', '@hubot end meeting').then =>
        expect(@room.messages).to.eql [
          ['alice', '@hubot start meeting']
          ['hubot', 'I have prepared the meeting.']
          ['alice', '@hubot end meeting']
          ['hubot', 'I have ended the meeting.']
        ]

  it 'complains about commands that require a meeting if there isn\'t one'

  it 'hears q+', testQPlusCmd('q+')
  it 'hears queue+', testQPlusCmd('queue+')

  it 'hears q-', testQMinusCmd('q-')
  it 'hears queue-', testQMinusCmd('queue-')

  it 'hears q?', testQueueQuery('q?')
  it 'hears queue?', testQueueQuery('queue?')

  it 'hears ack <name>', testAck('ack')
  it 'hears acks <name>', testAck('acks')
  it 'hears recognize <name>', testAck('recognize')
  it 'hears recognizes <name>', testAck('recognizes')
  it 'does not respond to ack without a name', ->
    @room.user.say('alice', '@hubot start meeting').then =>
      @room.user.say('alice', 'q+').then =>
        @room.user.say('alice', 'ack').then =>
          expect(@room.messages).to.eql [
            ['alice', '@hubot start meeting']
            ['hubot', 'I have prepared the meeting.']
            ['alice', 'q+']
            ['hubot', 'I see alice on the speaker list']
            ['alice', 'ack']
          ]

  it 'does not verbally respond to present+ or present-', ->
    @room.user.say('alice', '@hubot start meeting').then =>
      @room.user.say('alice', 'present+').then =>
        @room.user.say('alice', 'present-').then =>
          expect(@room.messages).to.eql [
            ['alice', '@hubot start meeting']
            ['hubot', 'I have prepared the meeting.']
            ['alice', 'present+']
            ['alice', 'present-']
          ]
