Db = require 'db'
App = require 'app'
Event = require 'event'
Comments = require 'comments'
Funnies = require 'funnies'
Timer = require 'timer'

exports.client_incr = (clicks) !->
	userId = App.userId()
	counter = Db.shared.ref 'counters', userId

#	if not counter.get()?
#		initUser()

	oldSorted = getSortedCounters()
	oldPos = oldSorted.indexOf userId

	counter.incr clicks

	decideFunny userId, counter.peek()

	newSorted = getSortedCounters()
	newPos = newSorted.indexOf userId

	if newPos isnt oldPos
		for i in [newPos+1..oldPos]
			Event.create
				lowPrio: newSorted[i]
				text: App.userName() + " outclicked you!"

getSortedCounters = ->
	counters = Db.shared.get('counters')
	(+k for k,v of counters).sort (a,b) -> counters[b] - counters[a]

# minimum time between funnies
MIN_TIME = 60
# minimum clicks between funnies
MIN_CLICKS = 50

decideFunny = (userId, counter) !->
	info = Db.personal(userId).ref 'funnies'

	lastCount = info.get('lastCount') ? 0
	lastTime = info.get('lastTime') ? 0

	# you have all the info you need , now DECIDE!
	timePassed = App.time() - lastTime
	#log timePassed
	return if timePassed < MIN_TIME

	clicksPassed = counter - lastCount
	#log clicksPassed
	return if clicksPassed < MIN_CLICKS

	timeOdds = Math.min 1, ((timePassed - MIN_TIME) / (10 * MIN_TIME))

	counterOdds = Math.min 1, ((clicksPassed - MIN_CLICKS) / (10* MIN_CLICKS))

	#log counterOdds, ' * ', timeOdds, ' : ', counterOdds * timeOdds
	odds = counterOdds * timeOdds
	return if Math.random() > odds

	# yay, you get a funny! you get a funny! you get a funny!
	funny = Funnies.getRandom info.ref('seen')
	info.set 'current', funny
	info.set 'lastCount', counter
	info.set 'lastTime', App.time()
	Timer.set 6000, 'clearFunny', userId

#initUser = !->
#	userId = App.userId()
#	Db.shared.set('counters', userId, 0)

exports.onJoin = (userId) !->
	Db.shared.set('counters', userId, 0)

exports.clearFunny = (userId) !->
	Db.personal(userId).set 'funnies', 'current', null

exports.onLeave = (userId) !->
	Db.personal(userId).set('funnies', null)
	Db.shared.set('counters', userId, null)

### Run this once to migrate users' seenLines -Peter
exports.onUpgrade = !->
	for user in App.userIds()
		pdb = Db.personal(user)
		if (oldSeen = pdb.get('seenlines'))
			pdb.set 'funnies', 'seen', oldSeen
		pdb.set 'seenlines', null
		pdb.set 'funny', null
		pdb.set 'limit', null
		pdb.set 'odds', null
		pdb.set 'timelimit', null
###

###useful for debugging and fixes
exports.onUpgrade = !->
	for user in App.userIds()
		#Db.personal(user).set('funnies', null)
		Db.personal(user).set('limit', 0)
		Db.personal(user).set('timelimit', 0)
		Db.personal(user).set('odds', 60)
		Db.shared.counters.user.set('counters', 0)

###
