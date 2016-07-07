###

	Big thanks to Peter for his help, debugging and tips.

	Snippets of code in both client.coffee and server.coffee have been adapted from the Happening documentation and existing Happening plugins: Example, Photohunt and BombDefuse

###


###
done = Obs.create true Obs.observe !-> diff = player.get('score') - localPlayer.peek('score') return if diff is 0 done.set false setInterval (1/diff), !-> localPlayer.incr 'score' if player.get('score') is localPlayer.peek('score') done.set true
###

Comments = require 'comments'
Db = require 'db'
Dom = require 'dom'
Server = require 'server'
Ui = require 'ui'
Obs = require 'obs'
App = require 'app'
Plugin = require 'plugin'

exports.render = ->
	###
	# create local copy of the scores
	localScores = Obs.create {}
	Obs.observe !->
		Db.shared.iterate 'counters', (v) !->
			localScores.set 'counters', v.key(), v.peek()

	done = Obs.create true
	Obs.observe !->
		diff = player.get('score') - localPlayer.peek('score')
		return if diff is 0
		done.set false
		setInterval (1/diff), !->
			localPlayer.incr 'score'
			if player.get('score') is localPlayer.peek('score') done.set true
	###
	buffer = Obs.create 0

	Ui.card !->
		renderButton buffer

		renderFunny()

	renderScores buffer

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
		Obs.onTime 1000, !->
			bufferedClicks = buffer.peek()
			buffer.set(0)

			log 'buffered', bufferedClicks
			Server.sync 'incr', bufferedClicks, !->
				Db.shared.incr 'counters', App.userId(), bufferedClicks
			buffering.set false

renderFunny = !->
	Obs.observe !->
		funny = Db.personal.get('funnies')
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

renderScores = (buffer) !->
	Ui.list !->
		Dom.style margin: '0 15px'
		Db.shared.iterate 'counters',
			((counter) !-> renderScore(counter, buffer)),
			(counter) -> -(counter.get() + if (counter.key() is App.userId()) then buffer.get() else 0)

renderScore = (counter, buffer) !->
	Ui.item !->
		userId = +counter.key()
		if userId is App.userId()
			Dom.style fontWeight: 'bold'
		Ui.avatar
			key: App.userAvatar(userId)
			onTap: !-> App.showMemberInfo(userId)
		Dom.div !->
			Dom.style marginLeft: '10px', Flex: 1
			Dom.text App.userName(userId)
		Dom.div !->
			if userId is App.userId()
				Dom.text counter.get() + buffer.get()
			else
				Dom.text counter.get()
