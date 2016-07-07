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

buffer = Obs.create 0

exports.render = ->
	Ui.card !->
		renderButton()

		renderFunny()

	renderScores()

renderButton = !->
	Dom.div !->
		Dom.style _userSelect: 'none', textAlign: 'center', maxWidth: '700px', borderRadius: '10px', boxShadow: '0 0 10px #aaa', border: '4px solid '+Plugin.colors().highlight, padding: '10px 16px'
		Dom.div !->
			Dom.style textTransform: 'uppercase', fontWeight: 'bold', fontSize: '500%', color: Plugin.colors().highlight
			Dom.text "Click"

		Dom.onTap !->
			###
			counter = Db.shared.ref 'counters', App.userId()
			if counter?
				Server.sync 'incr', !->
					counter.incr()
			else
				Server.call 'incr'
			###
			###
			if not buffer.peek() # buffer still 0? then this is the first click
				Obs.onTime 1000, !-> flushBuffer buffer
				log 'buffered', buffer
			buffer.incr()
			log 'buffer' #, buffer.get()
			###

			buffer.incr()

			if buffer.get() is 1
				Obs.onTime 1000, !-> flushBuffer buffer

flushBuffer = !->
	#counter = Db.shared.ref 'counters', App.userId()
	log 'buffered', buffer.get()
	Server.sync 'incr', buffer.get() #, !->
		#counter.set(counter.get() + buffer.get())
	buffer.set(0)

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
		Db.shared.iterate 'counters', renderScore, (counter) -> -(counter.get() + if (+counter.key() is App.userId()) then buffer.get() else 0)

renderScore = (counter) !->
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
