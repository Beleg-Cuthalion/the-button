Db = require 'db'
App = require 'app'
Event = require 'event'
Comments = require 'comments'
Funnies = require 'funnies'
Timer = require 'timer'

exports.client_incr = !->
	userId = App.userId()
	counter = Db.shared.ref 'counters', userId

	if not counter.get()?
		initUser()

	oldSorted = getSortedCounters()
	oldPos = oldSorted.indexOf userId

	counter.incr()
	Db.shared.incr 'total'

	f = Math.floor(Math.random()*Db.personal(userId).get('odds'))
	if f is 25 and Db.personal(userId).get('limit') is 0 and Db.personal(userId).get('timelimit') is 0 #last two statements are redundant, but easier to remove time limit later on
		fun = Funnies.getRandom Db.personal(userId).ref('seenlines')
		Db.personal(userId).set('funnies', fun)
		Db.personal(userId).set('limit', 1)
		Db.personal(userId).set('timelimit', 1)
		Db.personal(userId).modify 'odds', (v) -> v*1.2
		Timer.set 6000, 'clearFunny', userId
		Timer.set 300000, 'clearTime', userId

	newSorted = getSortedCounters()
	newPos = newSorted.indexOf userId

	if newPos isnt oldPos
		for i in [newPos+1..oldPos]
			Event.create
				lowPrio: newSorted[i]
				text: App.userName() + " outclicked you!"

initUser = !->
	Db.personal(App.userId()).set('funnies', undefined)
	Db.personal(App.userId()).set('limit', 0)
	Db.personal(App.userId()).set('odds', 50)
	Db.personal(App.userId()).set('timelimit', 0)

getSortedCounters = ->
	counters = Db.shared.get('counters')
	(+k for k,v of counters).sort (a,b) -> counters[b] - counters[a]

exports.clearFunny = (userId) !->
	Db.personal(userId).set 'funnies', undefined
	Db.personal(userId).set 'limit', 0

exports.clearTime = (userId) !->
	Db.personal(userId).set 'timelimit', 0
	log 'time cleared'

exports.onLeave = (userId) !->
	Db.personal(userId).set('funnies', null)
	Db.personal(userId).set('limit', null)
	Db.personal(userId).set('odds', null)
	Db.personal(userId).set('timelimit', null)
	Db.shared.set('counters', userId, null)

### useful for debugging and fixes
exports.onUpgrade = !->
	for user in App.userIds()
		#Db.personal(user).set('funnies', null)
		Db.personal(user).set('limit', 0)
		Db.personal(user).set('timelimit', 0)
		Db.personal(user).set('odds', 60)
###
