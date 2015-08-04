"use strict";

var skip = false
var selectionOverriden = false

function OnUpdateSelectedUnit( event )
{
	if (skip == true)
	{
		skip = false;
		// selectionOverriden = false;
		// $.Msg("skip")
		return
	}

	var iPlayerID = Players.GetLocalPlayer();
	var selectedEntities = Players.GetSelectedEntities( iPlayerID );
	var mainSelected = Players.GetLocalPlayerPortraitUnit();
	selectionOverriden = false;

	// $.Msg( "OnUpdateSelectedUnit, main selected index: "+mainSelected);
	// $.Msg( "Player "+iPlayerID+" Selected Entities ("+(selectedEntities.length)+")" );
	// $.Msg(selectedEntities);
	if (selectedEntities.length > 1 && IsMixedBuildingSelectionGroup(selectedEntities) )
	{
		// $.Msg( "IsMixedBuildingSelectionGroup, proceeding to deselect the buildings and get only the units ")
		// $.Msg( "Number of selected entities: " , selectedEntities.length)
		for (var i = 0; i < selectedEntities.length; i++) 
		{
			// $.Msg( "Iterating unit: ", Entities.GetUnitName(selectedEntities[i]));
			skip = true; // Makes it skip an update
			if (!IsCustomBuilding(selectedEntities[i]) && !selectionOverriden)
			{
				// $.Msg( "Starting");
				selectionOverriden = true;
				GameUI.SelectUnit(selectedEntities[i], false);

				// GameUI.SelectUnit(selectedEntities[i], false);
				//$.Msg( "New selection group");
			}
			else if (!IsCustomBuilding(selectedEntities[i]))
			{
				// $.Msg( "Selecting ")
				GameUI.SelectUnit(selectedEntities[i], true);
			}
			else if (selectionOverriden)
			{
				// $.Msg( "Base found")
				// GameUI.SelectUnit(selectedEntities[i], true);
				// skip = false;
				// selectionOverriden = false;
				// // OnUpdateSelectedUnit(event);
				// return
			}
		}	
	}

	// selectionOverriden = false;

}

// Returns whether the selection group contains both buildings and non-building units
function IsMixedBuildingSelectionGroup ( entityList )
{
	var buildings = 0
	var nonBuildings = 0
	for (var i = 0; i < entityList.length; i++) 
	{
		if (IsCustomBuilding(entityList[i]))
		{
			buildings++
		}
		else
		{
			nonBuildings++
		}
	}
	//$.Msg( "Buildings: ",buildings, " NonBuildings: ", nonBuildings)
	return (buildings>0 && nonBuildings>0)
}

function IsCustomBuilding( entityIndex )
{
	var unitName = Entities.GetUnitName( entityIndex )
	// $.Msg("Units name: ",unitName)
	if (unitName == "base")
	{
		//$.Msg(entityIndex+" IsCustomBuilding - Ability Index: "+ ability_building)
		return true
	}
	else
		return false
}

function SelectNewUnit( data )
{
	$.Msg("Selecting new unit for this player")
	GameUI.SelectUnit(data['entityIndex'], false);
}


(function () {
	GameEvents.Subscribe( "dota_player_update_selected_unit", OnUpdateSelectedUnit );
	GameEvents.Subscribe( "select_new_unit", SelectNewUnit );
})();