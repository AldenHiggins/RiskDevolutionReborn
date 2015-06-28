-- The overall game state has changed
function GameMode:_OnGameRulesStateChange(keys)
  local newState = GameRules:State_Get()
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

-- An entity died
function GameMode:_OnEntityKilled( keys )
  -- The Unit that was Killed
  local killedUnit = EntIndexToHScript( keys.entindex_killed )
  print (killedUnit:GetUnitName() .. " was killed")

  -- -- The Killing entity
  -- local killerEntity = nil
  -- if keys.entindex_attacker ~= nil then
  --   killerEntity = EntIndexToHScript( keys.entindex_attacker )
  -- end

  local circle = Entities:FindByName(nil, killedUnit:GetUnitName() .. " Spawn")

  if circle == nil then
    return
  end

  local base = Entities:FindByName(kiledUnit, killedUnit:GetUnitName())
  -- Return if no base could be found
  if base == nil then
    return
  end

  -- for ent,other in pairs(Entities:FindInSphere(nil, circle:GetOrigin(), 1000)) do
  --   print ("Entity name: " .. other:GetName())
  -- end

  local killerEntity = nil
  local closestDistance = 10000000
  local entitiesNearKilled = Entities:FindAllInSphere(circle:GetOrigin(), 600)
  for _,unit in pairs(entitiesNearKilled) do
    if unit:GetName() == "npc_dota_creature" then
      if unit:GetUnitName() == "npc_dota_risk_rifleman" then
        local circleOrigin = circle:GetOrigin()
        local killerOrigin = unit:GetOrigin()
        local currentDistance = (killerOrigin[1] - circleOrigin[1]) * (killerOrigin[1] - circleOrigin[1]) + (killerOrigin[2] - circleOrigin[2]) * (killerOrigin[2] - circleOrigin[2])

        if currentDistance < closestDistance then
          if unit:IsAlive() == true then
            closestDistance = currentDistance
            killerEntity = unit
          end
        end
      end
    end
  end


  local color = nil
  if killerEntity == nil then
    print ("entity not found")
    color = TEAM_COLORS[killedUnit:GetTeam()]

    killerEntity = CreateUnitByName("npc_dota_risk_rifleman", circle:GetOrigin(), true, nil, nil, killedUnit:GetTeam())
    killerEntity:SetRenderColor(color[1], color[2], color[3])
    killerEntity:GetChildren()[3]:SetRenderColor(color[1], color[2], color[3])
    killerEntity:SetOwner(killedUnit:GetOwner())
  else
    print ("Another entity was found")
    color = TEAM_COLORS[killerEntity:GetTeam()]
    local killedPosition = killedUnit:GetOrigin()
    local killerPosition = killerEntity:GetOrigin()
    print ("Killed entity: " .. killedUnit:GetUnitName() .. " position: " .. killedPosition[1] .. " " .. killedPosition[2] .. " " .. killedPosition[3])
    print ("Killer entity: " .. killerEntity:GetUnitName() .. " position: " .. killerPosition[1] .. " " .. killerPosition[2] .. " " .. killerPosition[3])
    base:SetTeam(killerEntity:GetTeam())
    base:SetRenderColor(color[1], color[2], color[3])
    base:SetOwner(killerEntity:GetOwner())
    if killerEntity:GetOwner() == nil then
      print ("Killer entity has no owner....")
    else
      if killerEntity:GetOwner():GetPlayerID() == nil then
        print("Could not set base controllable by player")
      else
        base:SetControllableByPlayer(killerEntity:GetOwner():GetPlayerID(), true)
      end
    end

    
  end
  
  circle:SetTeam(killerEntity:GetTeam())
  circle:SetRenderColor(color[1], color[2], color[3])

  killerEntity:SetOrigin(circle:GetOrigin() + Vector(0, 0, 64))
  killerEntity:SetControllableByPlayer(0, true)
  killerEntity:SetUnitName(killedUnit:GetUnitName())

  -- Old game winning logic stuff
  if killedUnit:IsRealHero() then 
    DebugPrint("KILLED, KILLER: " .. killedUnit:GetName() .. " -- " .. killerEntity:GetName())
    if END_GAME_ON_KILLS and GetTeamHeroKills(killerEntity:GetTeam()) >= KILLS_TO_END_GAME_FOR_TEAM then
      GameRules:SetSafeToLeave( true )
      GameRules:SetGameWinner( killerEntity:GetTeam() )
    end

    --PlayerResource:GetTeamKills
    if SHOW_KILLS_ON_TOPBAR then
      GameRules:GetGameModeEntity():SetTopBarTeamValue ( DOTA_TEAM_BADGUYS, GetTeamHeroKills(DOTA_TEAM_BADGUYS) )
      GameRules:GetGameModeEntity():SetTopBarTeamValue ( DOTA_TEAM_GOODGUYS, GetTeamHeroKills(DOTA_TEAM_GOODGUYS) )
    end
  end
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:_OnConnectFull(keys)
  GameMode:_CaptureGameMode()
end