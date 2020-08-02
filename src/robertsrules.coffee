# Description
#   Robert's Rules of Order for Hubot
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   hubot hello - <what the respond trigger does>
#   orly - <what the hear trigger does>
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   AJ Jordan <alex@strugee.net>

canonicalizeName = (res) ->
  name = res.match.groups.name
  name = name.trim() if name
  if name == 'me' or not name
    name = res.envelope.user.name

qPlus = (res) ->
  name = canonicalizeName res
  res.send "q+ triggered: " + name

qMinus = (res) ->
  name = canonicalizeName res
  res.send "q- triggered: " + name

module.exports = (robot) ->

  # Obviously we could jam all these into the same regexp, but it's so much easier to read this way
  robot.hear /^q\+(?<name> .+)?$/, qPlus
  robot.hear /^queue\+(?<name> .+)?$/, qPlus
  robot.hear /^(?<name>.+ )?raises? hand$/, qPlus
  robot.hear /^sees (?<name>.+ ) raise hands?$/, qPlus

  # Ditto
  robot.hear /^q\-(?<name> .+)?$/, qMinus
  robot.hear /^queue\-(?<name> .+)?$/, qMinus
  robot.hear /^(?<name>.+ )?lowers? hand$/, qMinus
  robot.hear /^sees (?<name>.+ ) lower hands?$/, qMinus

  robot.hear /orly/, (res) ->
    res.send "yarly"
