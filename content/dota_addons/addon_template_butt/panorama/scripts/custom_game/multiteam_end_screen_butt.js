"use strict";

var listen = GameEvents.Subscribe( "endscreen_butt", function(answer){
	// $.Msg("endscreen_butt answer received", answer);
	var rootPanel = $.GetContextPanel().GetParent().FindChildrenWithClassTraverse("EndScreenRoot")[0];
	for ( var playerId in answer ){
			var answerPlayer = answer[playerId];
			var playerPanel = rootPanel.FindChildTraverse( "_dynamic_player_" + playerId );
			for ( var arg in answerPlayer ){
				var argPanel = playerPanel.FindChildTraverse(arg+"Container");
				if ( argPanel ){
					argPanel.GetChild(0).text=answerPlayer[arg];
				}
			}
			playerIDs[playerId]={team : teamId};
	}
	GameEvents.Unsubscribe(listen);
});

var playerIDs = {};
for ( var teamId of Game.GetAllTeamIDs() ){
	for ( var playerId of Game.GetPlayerIDsOnTeam( teamId ) ){
		playerIDs[playerId]={team : teamId};
	}
}

GameEvents.SendCustomGameEventToServer( "endscreen_butt", playerIDs );