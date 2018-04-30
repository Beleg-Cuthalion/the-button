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
FINALNUMBER = 1000000

exports.render = ->
	# create local copy of the scores
	localScores = Obs.create {}
	copied = {}
	started = Obs.create false
	finalReached = Obs.create (Db.shared.peek 'counters', App.userId() >= FINALNUMBER)
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
		Dom.style transition: 'background 14s ease', height: '138px', boxSizing: 'border-box'
		Obs.observe !->
			return unless finalReached.get()
			Dom.style background: '#333', color: '#ffd700', overflow: 'hidden'
		renderButton finalReached, Db.shared.ref('counters', App.userId()), buffer
		#renderMagic localScores
		Obs.observe !->
			renderFunny() unless finalReached.get()

	Obs.observe !->
		Db.shared.iterate 'counters', (counter) !-> started.set true
	Obs.observe !->
		if started.get()
			renderScores localScores

renderButton = (finalReached, count, buffer) !->
	animationDone = Obs.create finalReached.peek()
	buttonText = Obs.create (if finalReached.peek() then "WINNER" else "Click")
	doneSpin = animationDone.peek()

	buffering = Obs.create false
	Dom.div !->
		Dom.div !->
			Dom.style
				transition: 'border 6s ease'
				_userSelect: 'none'
				textAlign: 'center'
				maxWidth: '700px'
				borderRadius: '10px'
				boxShadow: '0 0 10px #aaa'
				padding: '10px 16px'
			Obs.observe !->
				Dom.style border: "4px solid #{if finalReached.get() then '#ffd700' else Plugin.colors().highlight}"

			Dom.div !->
				Dom.style
					textTransform: 'uppercase'
					fontWeight: 'bold'
					fontSize: '500%'
					transition: 'color 6s ease'
				Obs.observe !->
					Dom.style color: (if finalReached.get() then '#ffd700' else Plugin.colors().highlight)

				Obs.observe !-> Dom.text buttonText.get()

			Obs.observe !->
				if not finalReached.get()
					Dom.onTap !->
						if true or count?.get() is (FINALNUMBER - 1)
							finalReached.set true
							Server.sync 'incr', 1
						else
							buffering.set true
							buffer.incr()
				else
					Dom.onTap !->
						animationDone.set false
						Obs.emit()
						animationDone.set true

			buttonEl = Dom.get()
			unless finalReached.peek()
					Obs.observe !->
						return unless finalReached.get() and not animationDone.get() and not doneSpin
						buttonEl.style transition: 'border 6s ease, transform 5s ease'

						rotY = Obs.create 0
						scl = Obs.create 1
						Obs.observe !->
							buttonEl.style transform: "rotateY(#{rotY.get()}deg) scale(#{scl.get()})"
						spinning = Obs.create true
						Obs.observe !->
							if spinning.get()
								Obs.interval 500, !->
									rotY.set (rotY.get() + 360)
								Obs.onTime 5000, !->
									spinning.set false
							else
								buttonEl.style transition: 'border 6s ease, transform 1s ease, opacity 1s ease'
								scl.set 10
								buttonEl.style opacity: 0
								Obs.onTime 1000, !->
									scl.set 1
									buttonEl.style opacity: 1
									buttonText.set "WINNER"
									Obs.onTime 1000, !->
										animationDone.set true
										doneSpin = true

		wrapperEl = Dom.get()
		Obs.observe !->
			if finalReached.get() and animationDone.get()
				Dom.div !->
					Dom.style transform: 'translateY(100px)', padding: '0 20%', fontSize: '1.3em', textAlign: 'justify'
					Dom.text "klhsa dbfsa bfha sdk bh adsfbh bfa dhs f dsbfsdfh sd fhksd hgdshfgs d ahfghds afg ksg fkhjsdg adsv fhjkgklhsa dbfsa bfha sdk bh adsfbh bfa dhs f dsbfsdfh sd fhksd hgdshfgs d ahfghds afg ksg fkhjsdg adsv fhjkgklhsa dbfsa bfha sdk bh adsfbh bfa dhs f dsbfsdfh sd fhksd hgdshfgs d ahfghds afg ksg fkhjsdg adsv fhjkgklhsa dbfsa bfha sdk bh adsfbh bfa dhs f dsbfsdfh sd fhksd hgdshfgs d ahfghds afg ksg fkhjsdg adsv fhjkgklhsa dbfsa bfha sdk bh adsfbh bfa dhs f dsbfsdfh sd fhksd hgdshfgs d ahfghds afg ksg fkhjsdg adsv fhjkgklhs a dbfsa bfha sdk bh adsfbh bfa dhs f dsbfsdfh sd fhksd hgdshfgs d ahfghds afg ksg fkhjsdg adsv fhjkgklhsa dbfsa bfha sdk bh adsfbh bfa dhs f dsbfsdfh sd fhksd hgdshfgs d ahfghds afg ksg fkhjsdg adsv fhjkgklhsa dbfsa bfha sdk bh adsfbh bfa dhs f dsbfsdfh sd fhksd hgdshfgs d ahfghds afg ksg fkhjsdg adsv fhjkgklhsa dbfsa bfha sdk bh adsfbh bfa dhs f dsbfsdfh sd fhksd hgdshfgs d ahfghds afg ksg fkhjsdg adsv fhjkg"

				Obs.onTime 1000, !->
					wrapperEl.style transition: 'transform 15s linear'
					wrapperEl.style transform: 'translateY(-120%)'
					Obs.onTime 15000, !->
						wrapperEl.style opacity: 0
						wrapperEl.style transition: 'opacity 1s ease'
						Obs.onTime 300, !->
							wrapperEl.style opacity: 1, transform: 'translateY(0)'


	Obs.observe !->
		return unless buffering.get()
		Obs.onTime BUFFER_TIME, !->
			bufferedClicks = buffer.peek()
			buffer.set(0)

			Server.sync 'incr', bufferedClicks, !->
				Db.shared.incr 'counters', App.userId(), bufferedClicks
			buffering.set false

renderMagic = (localScores) !->
	Obs.observe !->
		userCurrent = localScores.get('counters', App.userId())
		if userCurrent >= FINALNUMBER and userCurrent < FINALNUMBER + 1000
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
						Dom.text "I'll be damned, that is one absurd amount of clicks. Bloody well done, " + App.userName(App.userId()) + "! But remember: with great clicking power comes great clicking responsibility."

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
				Dom.text App.userName(userId) + (if counter.get() >= FINALNUMBER then " 👑" else "")
			Dom.div !->
				Dom.text counter.get()
