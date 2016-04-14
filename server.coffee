Db = require 'db'
App = require 'app'
Event = require 'event'
Comments = require 'comments'

exports.onInstall = !->
    Db.shared.set('counters', App.userId(), 0)
    Db.shared.set 'total', 0
    for user in App.userIds()
        Db.personal(user).set('funnies', null)
        Db.personal(user).set('limit', 0)
        Db.personal(user).set('odds', 50)
        Db.personal(user).set('timelimit', 0)

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
    "That's one smell click for a man, one tiny click for mankind."
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
    "Didn't I tell you? I kill a kitten everytime you click this button."
    "(try clicking in all four corners of the button)"
    "Click on, thorugh the wind, click on trough the rain, though your dreams be tossed and blown"
    "Wait, did I just have a déjà vu? Again?"
    "Follow the white rabbit."
    "I have the heart of a lion and a lifetime ban from Wildlands."
    "A Freudian Slip is when you say one thing and mean your mother"
    "I just read a book about Stockholm Syndrome. It was pretty bad at first, but, by the end, I liked it."
    "A termite walks into the bar and asks, 'Is the bar tender here?'"
    "What did the pirate say when he turned 80? 'Aye Matey!'"
    "What did they give the guy who invented the doorknocker? A no-bell prize."
    "What do you get when you cross a dyslexic, an insomniac, and an agnostic? Someone who lays awake at night wondering if there is a dog."
    "Did you hear about the Italian chef that died? He pasta way."
    "Did you hear about the Italian chef that died? He ran out of thyme."
    "Why do cows have bells? Because their horns don't work"
    "If life gives you melons, you might have dyslexia."
    "This is all just a test. You're doing OK-ish."
    "That was some brilliant clicking there."
    "You don't even care, do you?"
    "The difference between us is that I can feel pain. You just click and click and click..."
    "What's orange and sounds like a parrot? A carrot."
    "Two nuns are sitting on a park bench. A man in a trench coat runs up and flashes them. The first nun has a stroke. The second nun tried but she couldn't reach."
    "What do wooden whales eat? Plankton"
    "What do quantum whales eat? Planckton"
    "Pavlov walks into a bar. The phone rings, and he says, 'Damn, I forgot to feed the dog.'"
    "It's hard to explain puns to kleptomaniacs because they always take things literally."
    "Animal testing is a terrible idea. They're just going to get nervous and give silly answers."
    "I think the phrase rhymes with Clicking Bell."
    "Two fish are in a tank, one says to the other: 'You man the guns, I'll drive!'"
    "So a baby seal walks into a club... "
    "What do you call an alligator in a vest? An Investigator."
    "What do you get when you cross a joke with a rhetorical question?"
    "A recent survey showed that 6 out of 7 dwarfs are not happy."
    "A plateau is the highest form of flattery"
    "I, for one, like Roman numerals."
    "Parallel lines have so much in common. It's a shame they'll never meet."
    "Don't you hate Matryoshka dolls? They're so full of themselves."
    "Apparently, someone in London gets stabbed every 52 seconds. Poor bastard."
    "Why does a chicken coop have two doors? If it had four doors it would be a chicken sedan."
    "How many Alzheimer's patients does it take to change a light bulb? To get to the other side."
    "Two cannibals were eating a clown – one said to the other, Does he taste funny to you?"
    "100 kilopascals go into a bar"
    "A photon goes to a hotel to check in. The bell hop asks him if he needs help with his luggage. He says 'No thanks, I'm traveling light'."
    "Did you know that you can cool yourself to -273.15˚C and still be 0K?"
    "There are two types of people in the world. Those who can extrapolate from incomplete data."
    "Why did the chicken cross the Möbius strip? To get to the same side."
    "Don't beleive anything atoms say, they make up everything!"
    "What does the B stand for in Benoit B. Mandlebrot? Benoit B. Mandlebrot."
    "A neutrino walks into a bar."
]

exports.onUpgrade = !->
    for user in App.userIds()
        Db.personal(user).set('funnies', null)
        Db.personal(user).set('limit', 0)
        Db.personal(user).set('timelimit', 0)

exports.client_incr = !->
    userId = App.userId()
    f = Math.floor(Math.random()*Db.personal(userId).get('odds'))
    oldSorted = (+k for k,v of Db.shared.get('counters') when +k).sort (a,b) -> Db.shared.get('counters', b) - Db.shared.get('counters', a)
    oldPos = oldSorted.indexOf userId
    Db.shared.modify 'counters', App.userId(), (v) -> v+1
    Db.shared.modify 'total', (v) -> v+1
    if f < 25 and Db.personal(userId).get('limit') is 0 #and Db.personal(userId).get('timelimit') is 0 #last two statements are redundant, but easier to remove time limit later on
        #r = Math.floor(Math.random()*lines.length)
        #Db.personal(userId).set('funnies', lines[r])
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
    i = rnd = Math.round(Math.random() * lines.length)
    seen = Db.personal(userId).ref('seenlines')
    while seen.get i
        break if i is (rnd - 1)
        i = i + 1 % lines.length # wrap around if needed

    # i is now the first unseen funny after rnd
    seen i, true
    return lines[i]
    Db.personal(userId).set('seenlines', i, true)


exports.client_clearfunnies = !->
    userId = App.userId()
    Db.personal(userId).set('funnies', null)
    Db.personal(userId).set('limit', 0)

exports.client_cleartime = !->
    userId = App.userId()
    Db.personal(userId).set('timelimit', 0)
