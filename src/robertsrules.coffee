# Description
#   Robert's Rules of Order for Hubot
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   hubot start meeting - start a new meeting
#   hubot end meeting - end the ongoing meeting
#   hubot who's here - list the people currently present for the meeting
#   present+ <name> - list yourself or (if present) <name> as present for the meeting
#   present- <name> - list yourself or (if present) <name> as no longer present for the meeting
#   q+/queue+ <name> - add yourself or (if present) <name> to the speaker queue
#   q-/queue- <name> - remove yourself or (if present) <name> from the speaker queue
#   q?/queue?/who's on queue - announce the speaker queue
#   ack/recognize <name> - acknowledge <name> to speak and remove them from the speaker queue
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   AJ Jordan <alex@strugee.net>

assert = require 'assert'
robertsRules = require 'roberts-rules'

meeting = null

wrapRequireMeeting = (fn) ->
  return (args...) ->
    if meeting is null
      res = args[0]
      res.send 'there isn\'t a meeting in progress!'
      return

    return fn.apply(this, args)

canonicalizeName = (res) ->
  name = res.match?.groups.name
  name = name.trim() if name
  if name == 'me' or not name
    name = res.message.user.name
  assert name
  return name

readSpeakerList = (res) ->
  text = 'I see '
  if meeting.speakerList.length > 0
    text += meeting.speakerList.join(', ')
  else
    text += 'no one'
  text += ' on the speaker list'
  res.send text

qPlus = (res) ->
  name = canonicalizeName res
  meeting.queueSpeaker name
  readSpeakerList res

qMinus = (res) ->
  name = canonicalizeName res
  meeting.dequeueSpeaker name
  readSpeakerList res

presentPlus = (res) ->
  name = canonicalizeName res
  meeting.addAttendee name

# TODO make this keep track of people who were there at one point, but no longer are
presentMinus = (res) ->
  name = canonicalizeName res
  meeting.removeAttendee name

# XXX maybe DRY this up with reading the speakers list
reportAttendees = (res) ->
  text = 'I see '
  if meeting.attendeeList.length > 0
    text += meeting.attendeeList.join(', ')
  else
    text += 'no one'
  text += ' present on this call'
  res.send text

module.exports = (robot) ->

  robot.respond /start meeting/, (res) ->
    meeting = robertsRules()
    res.send 'I have prepared the meeting.'

  robot.respond /end meeting/, (res) ->
    meeting = null
    res.send 'I have ended the meeting.'

  # Obviously we could jam all these into the same regexp, but it's so much easier to read this way

  # q+ and variants
  robot.hear /^q\+(?<name> .+)?$/, wrapRequireMeeting qPlus
  robot.hear /^queue\+(?<name> .+)?$/, wrapRequireMeeting qPlus
  robot.hear /^(?<name>.+ )?raises? hand$/, wrapRequireMeeting qPlus
  robot.hear /^sees (?<name>.+ ) raise hands?$/, wrapRequireMeeting qPlus

  # q- and variants
  robot.hear /^q\-(?<name> .+)?$/, wrapRequireMeeting qMinus
  robot.hear /^queue\-(?<name> .+)?$/, wrapRequireMeeting qMinus
  robot.hear /^(?<name>.+ )?lowers? hand$/, wrapRequireMeeting qMinus
  robot.hear /^sees (?<name>.+ ) lower hands?$/, wrapRequireMeeting qMinus

  # ack and variants
  robot.hear /^acks?(?<name> .+)$/, wrapRequireMeeting qMinus
  robot.hear /^recognizes?(?<name> .+)$/, wrapRequireMeeting qMinus

  # q? and variants
  robot.hear /^who('| i)s on queue\?$/, wrapRequireMeeting readSpeakerList
  robot.hear /^queue\?$/, wrapRequireMeeting readSpeakerList
  robot.hear /^q\?$/, wrapRequireMeeting readSpeakerList

  # present+ and variants
  robot.hear /^present\+(?<name> .+)?$/, wrapRequireMeeting presentPlus

  # present- and variants
  robot.hear /^present\-(?<name> .+)?$/, wrapRequireMeeting presentMinus

  # who's here? and variants
  robot.respond /who('| i)s here\?/, wrapRequireMeeting reportAttendees
  robot.respond /who('| i)s on the (phone|phone call|call|video|videocall|video call|)\?/, wrapRequireMeeting reportAttendees
