-- The overall game state has changed
function GameMode:_OnGameRulesStateChange(keys)
  local newState = GameRules:State_Get()

  if newState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
    GameRules:LockCustomGameSetupTeamAssignment( true )
    GameRules:SetCustomGameSetupAutoLaunchDelay(8)
  end
  
  if newState == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
    self.bSeenWaitForPlayers = true
  elseif newState == DOTA_GAMERULES_STATE_INIT then
    Timers:RemoveTimer("alljointimer")
  elseif newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
    local et = 6
    if self.bSeenWaitForPlayers then
      et = .01
    end
    Timers:CreateTimer("alljointimer", {
      useGameTime = true,
      endTime = et,
      callback = function()
        if PlayerResource:HaveAllPlayersJoined() then
          GameMode:PostLoadPrecache()
          GameMode:OnAllPlayersLoaded()
          return 
        end
        return 1
      end
      })
  elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    GameMode:OnGameInProgress()
  end
end

-- An NPC has spawned somewhere in game.  This includes heroes
function GameMode:_OnNPCSpawned(keys)
  local npc = EntIndexToHScript(keys.entindex)

  if npc:IsRealHero() and npc.bFirstSpawned == nil then
    npc.bFirstSpawned = true
    GameMode:OnHeroInGame(npc)
  end
end


-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:_OnConnectFull(keys)
  GameMode:_CaptureGameMode()
end