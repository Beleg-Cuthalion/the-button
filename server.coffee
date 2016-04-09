Db = require 'db'
App = require 'app'
Event = require 'event'
Comments = require 'comments'

exports.onInstall = !->
    #set the counter to 0 on plugin installation
    Db.shared.set('counters', App.userId(), 0)
    Db.shared.set 'total', 0
    for user in App.userIds()
        Db.personal(user).set('funnies', null)

lines = [
    "10000 years of human progress and here we are, clicking and clicking and clicking..."
    "Stop clicking me!"
    "Are you still here?"
    "ClickyMcClickface"
    "+1"
    "Up you go!"
    "Never gonna give you up!"
    "I'd appreciated if you would stop touching me. Seriously."
    "Clean your screen!"
    "May the clicks be with you."
    "Has it clicked yet? You're waisting my time. And yours."
    "CLICK"
    "Missed me."
    "rm -rf / --no-perserve-root"
    ":)"
    "----------->"
    "My mom always said: life was like a button. You never know who's gonna click."
    "We click, not because it is easy, but because it is hard."
    #App.userName() + ", tear down these clicks!"
    "Frankly, my dear, I don't give a click"
    "Final warning: Please. Stop. Clicking"
    "And god said: let there be clicks"
    "One Click to rule them all."
    "click+click=2clicks"
    "iClick"
    "5...4...3...2...1... CLICKERBIRDS ARE GO"
    "Did you know? Next time you click, your screen may burst."
    "You know, all this clicking is really starting to press my buttons."
    "Have you tried turning it off and on again?"
    "DOMINATING"
    "God save our royal Click"
    #"If I had a penny for everytime you clicked, I'd have" + (Db.shared.get 'counters', App.userId()) + "pennies."
    "Wanted! Someone to NOT click me all the time."
    "If you make it to the end, there *will* be cake."
    "Only a few more clicks til the finish line"
    "乁( ⁰͡ Ĺ̯ ⁰͡ ) ㄏ"
    "Like a broken pencil, this too may be pointless."
    "Everytime you click, something happens. Really."
    "Did you find the easter egg yet?"
    "How would you feel if someone kept touching you? 'Aroused'? Well, yeah... But besides that?"
    "[There was some text here]"
    "Didn't I say? I kill a kitten everytime you click this button."
    "(try clicking in all for corners of the button)"
]

exports.onUpgrade = !->
    for user in App.userIds()
        Db.personal(user).set('funnies', null)

exports.client_incr = !->
  userId = App.userId()
  f = Math.floor(Math.random()*50)
  oldSorted = (+k for k of Db.shared.get('counters') when +k).sort()
  oldPos = oldSorted.indexOf userId
  Db.shared.modify 'counters', App.userId(), (v) -> v+1
  Db.shared.modify 'total', (v) -> v+1

  if f == 25
      r = Math.floor(Math.random()*lines.length)
      Db.personal(userId).set('funnies', lines[r])
      log 'triggered'

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

exports.client_clearfunnies = !->
    userId = App.userId()
    Db.personal(userId).set('funnies', null)
