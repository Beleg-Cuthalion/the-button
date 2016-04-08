Comments = require 'comments'
Db = require 'db'
Dom = require 'dom'
Server = require 'server'
Ui = require 'ui'
Obs = require 'obs'
App = require 'app'

#funnies = Obs.create()

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
						Server.sync 'incr', !->
							Db.shared.modify 'counters', App.userId(), (v) -> v+1

			Obs.observe !->
				score = Db.shared.get('counters', App.userId())
				if Db.personal(App.memberId()).get('funnies') != ""
					Dom.div !->
						Dom.style fontWeight: 'bold', fontSize: '300%', textAlign: 'center'
						Dom.text Db.personal(App.memberId()).get('funnies')
					#Obs.onTime 3000, !->
					#	Db.personal.funnies.set(null)

				if score == 529
					Server.call 'funnies'

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
