"use strict";



// var curTimeDS = Game.GetGameTime() * 10;
// var teamPanel = $.GetContextPanel();
// playerPanel = $.CreatePanel( "Panel", playersContainer, playerPanelName );

function OnPlayerAdded( data )
{
	$.Msg("Player Connected!!!");

	var thisPanel = $.GetContextPanel();
	var playersPanel = thisPanel.FindChild( "PlayerContainer" );
	// Clear all of the players out
	playersPanel.RemoveAndDeleteChildren();
	// Get the list of playerIDs
	var playerIDs = Game.GetAllPlayerIDs();
	// var playerIDs = [2,3];
	var playerIDindex;
	// playerIDs.length
	for (playerIDindex = 0; playerIDindex < playerIDs.length; playerIDindex++)
	{
		// Generate a new panel for this player
		var playerID = playerIDs[playerIDindex];

		var newPlayerPanelName = "PlayerScoreBoardPanel" + playerID;
		var newPlayerPanel = $.CreatePanel( "Panel", playersPanel, newPlayerPanelName);
		newPlayerPanel.AddClass("PlayerPanel");

		// Set the color of the player
		var playerInfo = Game.GetPlayerInfo( playerID );
		var teamColor = GameUI.CustomUIConfig().team_colors[ playerInfo.player_team_id ];
		if ( teamColor )
		{
			newPlayerPanel.style.backgroundColor = teamColor;
		}

		// Now create the panels for the player's income and unit count
		var playerIncome = $.CreatePanel("Label", newPlayerPanel, "PlayerIncome");
		playerIncome.text = "4";
		var playerUnitCount = $.CreatePanel("Label", newPlayerPanel, "PlayerUnitCount");
		playerUnitCount.text = "0/50";
		// Add the resource icons to this panel
		var foodImage = $.CreatePanel("Image", newPlayerPanel, "FoodImage");
		var goldImage = $.CreatePanel("Image", newPlayerPanel, "GoldImage");
	}
}

function OnUnitCountChange( args )
{
	var playerPanelName = "PlayerScoreBoardPanel" + args['playerID'];
	$.Msg(playerPanelName);
	var playerPanel = $.GetContextPanel().FindChild("PlayerContainer").FindChild(playerPanelName);
	var playerUnitCount = playerPanel.FindChild("PlayerUnitCount");
	var newText = args['newUnitCount'] + "/50";
	playerUnitCount.text = newText;
}

function OnIncomeChange( args )
{
	var playerPanelName = "PlayerScoreBoardPanel" + args['playerID'];
	$.Msg("Income: ", playerPanelName);
	var playerPanel = $.GetContextPanel().FindChild("PlayerContainer").FindChild(playerPanelName);
	var playerIncome = playerPanel.FindChild("PlayerIncome");
	var newText = args['newIncome'];
	playerIncome.text = newText;
}

function UpdateTimer( args )
{
	// var curTimeDS = Game.GetGameTime() * 10;

	var playerPanel = $.GetContextPanel().FindChild("VicPanel").FindChild("Timer");
	var minutes = Game.GetDOTATime(false, false) / 60;
	minutes = minutes.toString(); //If it's not already a String
	minutes = minutes.slice(0, (minutes.indexOf("."))); //With 3 exposing the hundredths place

	var seconds = Game.GetDOTATime(false, false) % 60;
	var minutesAndSeconds = minutes + ":" + seconds.toFixed(0);
	playerPanel.text = minutesAndSeconds; 
}

(function () {
	$.Msg("Running the scoreboard script!!!");

	GameEvents.Subscribe("timer", UpdateTimer);
	GameEvents.Subscribe("dota_player_pick_hero", OnPlayerAdded);
	GameEvents.Subscribe("player_unit_count_changed", OnUnitCountChange);
	GameEvents.Subscribe("player_income_changed", OnIncomeChange);
})();