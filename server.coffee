Db = require 'db'
App = require 'app'
Event = require 'event'
Comments = require 'comments'
Funnies = require 'funnies'

### useful for debugging
exports.onUpgrade = !->
    for user in App.userIds()
        Db.personal(user).set('funnies', null)
        Db.personal(user).set('limit', 0)
        Db.personal(user).set('timelimit', 0)
###

exports.client_incr = !->
    userId = App.userId()
    if Db.shared.get('counters', userId) is 1
            Db.personal(userId).set('funnies', undefined)
            Db.personal(userId).set('limit', 0)
            Db.personal(userId).set('odds', 50)
            Db.personal(userId).set('timelimit', 0)
    f = Math.floor(Math.random()*Db.personal(userId).get('odds'))
    oldSorted = (+k for k,v of Db.shared.get('counters') when +k).sort (a,b) -> Db.shared.get('counters', b) - Db.shared.get('counters', a)
    oldPos = oldSorted.indexOf userId
    Db.shared.modify 'counters', App.userId(), (v) -> v+1
    Db.shared.modify 'total', (v) -> v+1
    if f is 25 and Db.personal(userId).get('limit') is 0 and Db.personal(userId).get('timelimit') is 0 #last two statements are redundant, but easier to remove time limit later on
        fun = getRandomFunny(userId)
        Db.personal(userId).set('funnies', fun)
        Db.personal(userId).set('limit', 1)
        Db.personal(userId).set('timelimit', 1)
        Db.personal(userId).modify 'odds', (v) -> v*1.2
    newSorted = (+k for k,v of Db.shared.get('counters') when +k).sort (a,b) -> Db.shared.get('counters', b) - Db.shared.get('counters', a)
    newPos = newSorted.indexOf userId
    if newPos isnt oldPos
        for i in [newPos+1..oldPos]
            Event.create
                lowPrio: true
                text: App.userName(newSorted[i]) + " outclicked you!"

getRandomFunny = (userId) !->
    i = rnd = Math.round(Math.random() * Funnies.count())
    seen = Db.personal(userId).ref('seenlines')
    while seen.get i
        break if i is (rnd - 1)
        i = i + 1 % Funnies.count() # wrap around if needed
    # i is now the first unseen funny after rnd
    seen.set i, true
    Db.personal(userId).set('seenlines', i, true)
    return Funnies.getLine(i)

exports.client_clearfunnies = !->
    userId = App.userId()
    Db.personal(userId).set('funnies', undefined)
    Db.personal(userId).set('limit', 0)

exports.client_cleartime = !->
    userId = App.userId()
    Db.personal(userId).set('timelimit', 0)
