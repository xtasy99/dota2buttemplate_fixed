local Thinker = class({})

ListenToGameEvent("game_rules_state_game_in_progress", function()
		Timers:CreateTimer( 0, Thinker.Minute00 )
		Timers:CreateTimer( 20*60, Thinker.DontForgetToSubscribe )
		Timers:CreateTimer( 30*60, Thinker.LateGame )
		Timers:CreateTimer( Thinker.VeryVeryOften )
		Timers:CreateTimer( Thinker.VeryOften )
		Timers:CreateTimer( Thinker.Often )
		Timers:CreateTimer( Thinker.Regular )
		Timers:CreateTimer( Thinker.Seldom )
end, GameMode)

function Thinker:Minute00()
	print("The Game begins!")
	return nil -- does not repeat
end

function Thinker:DontForgetToSubscribe()
	-- print("20 minutes")
	return nil -- does not repeat
end

function Thinker:LateGame()
	-- print("30 minutes")
	return nil -- does not repeat
end

function Thinker:VeryVeryOften()
	-- print("every 10 seconds")
	return 10
end

function Thinker:VeryOften()
	-- print("every minute")
	return 1*60
end

function Thinker:Often()
	-- print("every 5 minutes")
	return 5*60
end

function Thinker:Regular()
	-- print("every 15 minutes")
	return 15*60
end

function Thinker:Seldom()
	-- print("every 30 minutes")
	return 30*60
end
