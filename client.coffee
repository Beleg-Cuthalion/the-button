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

exports.render = ->
	Ui.card !->
		Dom.div !->
			Dom.style _userSelect: 'none'
			Dom.div !->
				Dom.style textAlign: 'center', maxWidth: '700px', borderRadius: '10px', boxShadow: '0 0 10px #aaa', border: '4px solid '+Plugin.colors().highlight, padding: '10px 16px'
				Dom.div !->
					Dom.style textTransform: 'uppercase', fontWeight: 'bold', fontSize: '500%', color: Plugin.colors().highlight
					Dom.text "Click"
				Dom.onTap !->
					counters = Db.shared.ref 'counters', App.userId()
					if counters?
						Server.sync 'incr', !->
							counters.incr()
					else
						Server.call 'incr'

		Obs.observe !->
			funny = Db.personal.get('funnies')
			if funny?
				Dom.div !->
					Dom.style fontWeight: 'bold', fontSize: '300%', textAlign: 'center'
					Dom.text funny
				Obs.onTime 6000, !->
					Server.sync 'clearfunnies', !->
				    	Db.personal.set('funnies', undefined)
				Obs.onTime 300000, !->
					Server.sync 'cleartime', !->
						Db.personal.set('timelimit', 0)

	Ui.list !->
		Dom.style margin: '0 15px'
		Db.shared.iterate 'counters', (counter) !->
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
					Dom.text counter.get()
		, (counter) -> -counter.get()
