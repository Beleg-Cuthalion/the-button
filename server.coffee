Db = require 'db'
App = require 'app'
Event = require 'event'
Comments = require 'comments'

exports.onInstall = !->
    #set the counter to 0 on plugin installation
    #clicks = Db.shared.set 'counters', App.userId(), 0
    #total = Db.shared.set 'total', 0
    Db.personal(App.memberId()).set('funnies', 0)

#exports.onUpgrade = !->
    #Db.personal(App.memberId()).modify 'funnies', "frick"

exports.client_incr = !->
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

exports.client_funnies = !->
  lines = [
    "Stop clicking me!"
    "Are you still here?"
    "ClickyMcClickface"
    "+1"
    "Up you go!"
    "Never gonna give you up!"
    "I'd appreciated if you would stop touching me. Seriously."
    "Clean your screen!"
    "May the clicks be with you"
    "Has it clicked yet? You're waisting my time. And yours."
    "CLICK"
    "Missed me"
    "rm -rf / --no-perserve-root"
    ":)"
    "----------->"
    "My mom always said: life"
    "We click, not because it is easy, but because it is hard"
    App.userName() + ", tear down these clicks!"
    "Frankly, my dear, I don't give a click"
    "Final warning: Please. Stop. Clicking"
    "And god said: let there be clicks"
    "One Click to rule them all"
    "click+click=2clicks"
    "iClick"
    "5...4...3...2...1... CLICKERBIRDS ARE GO"
    "Did you know? Next time you click, your screen may burst"
    "You know, all this clicking is really starting to press my buttons"
    "Have you tried turning it off and on again?"
    "DOMINATING"
    "God save our royal Click"
    "If I had a penny for everytime you clicked, I'd have" + Db.shared.get 'counters', App.userId()+ "pennies"
    ]

  r = Math.floor(Math.random()*29)
  Db.personal(App.memberId()).set('funnies', "test")
