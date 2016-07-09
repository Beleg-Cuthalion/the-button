###
	Big thanks to Peter for his help, debugging and tips.

	Snippets of code in both client.coffee and server.coffee have been adapted from the Happening documentation and existing Happening plugins: Example, Photohunt and BombDefuse
###

Comments = require 'comments'
Db = require 'db'
Dom = require 'dom'
Server = require 'server'
Ui = require 'ui'
Obs = require 'obs'
App = require 'app'
Plugin = require 'plugin'

BUFFER_TIME = 1000

exports.render = ->
	# create local copy of the scores
	localScores = Obs.create {}
	copied = {}
	started = Obs.create false
	Obs.observe !->
		Db.shared.iterate 'counters', (v) !->
			# just copy once!
			return if copied[v.key()]
			copied[v.key()] = true
			localScores.set 'counters', v.key(), v.peek()

	buffer = Obs.create 0
	# keep app user's local score synced with buffer
	Obs.observe !->
		oldScore = Db.shared.get('counters', App.userId()) ? 0
		newScore = oldScore + buffer.get()
		return if newScore is 0
		localScores.set 'counters', App.userId(), newScore
		started.set true

	Ui.card !->
		renderButton buffer

		renderFunny()

	Obs.observe !->
		Db.shared.iterate 'counters', (counter) !-> started.set true
	Obs.observe !->
		if started.get()
			renderScores localScores

renderButton = (buffer) !->
	buffering = Obs.create false
	Dom.div !->
		Dom.style _userSelect: 'none', textAlign: 'center', maxWidth: '700px', borderRadius: '10px', boxShadow: '0 0 10px #aaa', border: '4px solid '+Plugin.colors().highlight, padding: '10px 16px'
		Dom.div !->
			Dom.style textTransform: 'uppercase', fontWeight: 'bold', fontSize: '500%', color: Plugin.colors().highlight
			Dom.text "Click"

		Dom.onTap !->
			buffering.set true
			buffer.incr()

	Obs.observe !->
		return unless buffering.get()
		Obs.onTime BUFFER_TIME, !->
			bufferedClicks = buffer.peek()
			buffer.set(0)

			Server.sync 'incr', bufferedClicks, !->
				Db.shared.incr 'counters', App.userId(), bufferedClicks
			buffering.set false

renderFunny = !->
	Obs.observe !->
		funny = Db.personal.get('funnies', 'current')
		if funny?
			Dom.div !->
				Dom.animate
						create:
							opacity: 1 # target
							initial:
								opacity: 0
						remove:
							opacity: 0 # target
							initial:
								opacity: 1
						content: !->
						Dom.style fontSize: '150%', textAlign: 'center', padding: "30px 5px 15px"
						Dom.text funny

renderScores = (localScores) !->
	done = Obs.create true

	# make a list of all the player ids
	playerList = Obs.create {}
	Obs.observe !->
		Db.shared.iterate 'counters', (counter) !->
			userId = + counter.key()
			return if userId is App.userId()
			playerList.set userId, true

	# animate scores when receiving someone's buffered clicks
	playerList.iterate (userId) !->
		done.get() # subscribe

		realCounter = Db.shared.ref('counters', userId.key())
		localCounter = localScores.ref('counters', userId.key())
		diff = realCounter.get() - localCounter.peek()
		return if diff <= 0
		done.set false
		stepTime = Math.round(BUFFER_TIME/diff)
		Obs.interval stepTime, !->
			localCounter.incr()
			if realCounter.peek() <= localCounter.peek()
				done.set true

	Ui.list !->
		Dom.style margin: '0 15px'
		localScores.iterate 'counters', renderScore, (counter) -> -counter.get()

renderScore = (counter) !->
	userId = +counter.key()
	if counter.get()?
		Ui.item !->
			if userId is App.userId()
				Dom.style fontWeight: 'bold'
			Ui.avatar
				key: App.userAvatar(userId)
				onTap: !-> App.showMemberInfo(userId)
			Dom.div !->
				Dom.style marginLeft: '10px', Flex: 1
				Dom.text App.userName(userId)
			Dom.div !->
				Dom.text counter.get()
