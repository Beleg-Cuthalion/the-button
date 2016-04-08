Db = require 'db'
App = require 'app'
Event = require 'event'
Comments = require 'comments'

exports.onInstall = ->
  #set the counter to 0 on plugin installation
  clicks = Db.shared.set 'counters', App.userId(), 0
  total = Db.shared.set 'total', 0

exports.client_incr = ->
  userId = App.userId()
  oldSorted = (+k for k of Db.shared.get('counters') when +k).sort()
  oldPos = oldSorted.indexOf userId
  Db.shared.modify 'counters', App.userId(), (v) -> v+1
  Db.shared.modify 'total', (v) -> v+1
  newSorted = (+k for k of Db.shared.get('counters') when +k).sort()
  newPos = newSorted.indexOf userId
  runnerUp = newSorted[newPos+1]
  if newPos != oldPos
  	Comments.post
  		u: App.userId()
  		a: runnerUp
  		pushText: App.userName() + " just outclicked you!"
  		path: '/'

  # Db.shared.modify 'counters', App.userId(), (v) -> v+1
  # Db.shared.modify 'total', (v) -> v+1
  # Db.shared.iterate 'counters', (counter) !->
  #   Db.shared.set 'newleader', App.userId()
  #  if Db.shared.get('leader') != Db.shared.get('newleader')
  #    Event.create
  #      text: "New leader"
