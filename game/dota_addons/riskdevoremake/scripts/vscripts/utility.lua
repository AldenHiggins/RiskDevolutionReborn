function MoveToRallyPoint( event )
    local caster = event.caster
    local target = event.target

    local player = caster:GetPlayerOwner()
    local hero = player:GetAssignedHero()

    local playerID = player:GetPlayerID()
    if GameMode:CheckUnitCount(playerID, player, target) == false then
        return
    end

    target:SetOwner(hero)

    -- Recolor the unit you spawned
    local color = TEAM_COLORS[caster:GetTeam()]

    target:SetRenderColor(color[1], color[2], color[3])

    print ("Created: .. " .. target:GetUnitName())
    -- if target:GetUnitName() == "npc_dota_risk_general" then
    --     return
    -- end

    target:GetChildren()[3]:SetRenderColor(color[1], color[2], color[3])
end

function GetInitialRallyPoint( event )
    local caster = event.caster
    local origin = caster:GetAbsOrigin()

    local result = {}
    if origin then
        table.insert(result,origin)
    else
        print("Error: Unit cannot be spawned.")
    end
    
    return result
end

function GameMode:CheckUnitCount(playerID, player, target)
    print ("This player has: " .. self.unitCount[playerID] .. " many units")
    if self.unitCount[playerID] > UNITS_PER_PLAYER then
        target:RemoveSelf()
        PlayerResource:SetGold(playerID, PlayerResource:GetGold(playerID) + 1, true)
        GameRules:SendCustomMessage("You have too many units!  Clear up some space for new ones!", player:GetTeam(), 1);
        return false
    end
    self.unitCount[playerID] = self.unitCount[playerID] + 1

    -- Fire event to the UI that a player count has changed
    FireGameEvent('player_unit_count_changed', { teamNumber = player:GetTeam(), newUnitCount = self.unitCount[playerID]})

    return true
end

function GameMode:AllocateBases()
  print("Allocating bases")
  local teamIndex = 1
  -- Iterate through all of the territories
  for territory,totalBases in pairs(self.territories) do
    -- Update all of the bases in the territory
    for baseNumber = 1, totalBases do
      local teamNumber = self.teamNumbers[teamIndex]
      print (territory .. " " .. baseNumber)
      local base = Entities:FindByName(nil, territory .. " " .. baseNumber)
      base:SetTeam(teamNumber)
      local color = TEAM_COLORS[teamNumber]
      base:SetRenderColor(color[1], color[2], color[3])
      base:RemoveModifierByName("modifier_invulnerable")

      local circle = Entities:FindByName(nil, territory .. " " .. baseNumber .. " Spawn")
      circle:Destroy()
      -- circle:SetTeam(teamNumber)
      -- circle:SetRenderColor(color[1], color[2], color[3])
      -- circle:SetOrigin(base:GetOrigin())

      -- local newUnit = CreateUnitByName("npc_dota_risk_rifleman", circle:GetOrigin(), true, nil, nil, teamNumber)
      -- newUnit:SetRenderColor(color[1], color[2], color[3])
      -- newUnit:GetChildren()[3]:SetRenderColor(color[1], color[2], color[3])
      -- newUnit:SetUnitName(territory .. " " .. baseNumber)

      teamIndex = teamIndex + 1
      if teamIndex > 10 then
        teamIndex = 1
      end
    end
  end
end

function GameMode:IncomeCheck()
  -- Zero out all of the player incomes
  for playerID,player in pairs(self.players) do
    self.playerIncomes[playerID] = BASE_PLAYER_INCOME
  end

  -- Iterate through all of the territories
  for territory, totalBases in pairs(self.territories) do
    local allTheSameTeam = true
    local base = Entities:FindByName(nil, territory .. " " .. 1)
    local playerWhoMayOwnAllBases = base:GetOwner()
    local territorySpawn = Entities:FindByName(nil, territory .. " Territory")
    local territoryLabel = Entities:FindByName(nil, territory .. " Label")
    -- Early quit out in case not all the players have connected yet
    if playerWhoMayOwnAllBases == nil then
      goto continue
    end
    -- print ("First base player: " .. playerWhoMayOwnAllBases)
    -- Update all of the bases in the territory
    for baseNumber = 2, totalBases do
      local nextBase = Entities:FindByName(nil, territory .. " " .. baseNumber)
      -- print ("This next player: " .. base:GetOwner())
      if nextBase:GetOwner() ~= playerWhoMayOwnAllBases then
        allTheSameTeam = false
        territorySpawn:SetRenderColor(255, 255, 255)
        territoryLabel:SetRenderColor(255, 255, 255)
        break
      end
    end


    -- If this territory is entirely owned by one player, add to their income
    if allTheSameTeam == true then
      print("Adding to the player's income!!!")
      self.playerIncomes[playerWhoMayOwnAllBases:GetPlayerID()] = self.playerIncomes[playerWhoMayOwnAllBases:GetPlayerID()] + totalBases
      local color = TEAM_COLORS[base:GetTeam()]
      territorySpawn:SetRenderColor(color[1], color[2], color[3])
      territorySpawn:SetTeam(base:GetTeam())
      territoryLabel:SetRenderColor(color[1], color[2], color[3])
      territoryLabel:SetTeam(base:GetTeam())

      -- Generate free units every turn
      -- local newUnit = CreateUnitByName("npc_dota_risk_rifleman", territorySpawn:GetOrigin(), true, nil, nil, base:GetTeam())
      -- newUnit:SetRenderColor(color[1], color[2], color[3])
      -- newUnit:GetChildren()[3]:SetRenderColor(color[1], color[2], color[3])
      -- newUnit:SetOwner(base:GetOwner())
      -- newUnit:SetControllableByPlayer(base:GetOwner():GetPlayerID(), true)
    end

    ::continue::
  end


  for playerID,player in pairs(self.players) do
    PlayerResource:SetGold(playerID, PlayerResource:GetGold(playerID) + self.playerIncomes[playerID], true)
    FireGameEvent('player_income_changed', { teamNumber = player:GetTeam(), newIncome = self.playerIncomes[playerID]})
    -- Check to see if the player has won the game
    if self.playerIncomes[playerID] > 10 then
      GameRules:SetSafeToLeave( true )
      GameRules:SetGameWinner( player:GetTeam() )
    end
  end
  return TURN_TIME
end

-- A player picked a hero
function GameMode:OnPlayerPickHero(keys)
  DebugPrint('[BAREBONES] OnPlayerPickHero')
  DebugPrintTable(keys)

  local heroClass = keys.hero
  local heroEntity = EntIndexToHScript(keys.heroindex)
  local player = EntIndexToHScript(keys.player)
  local playerID = heroEntity:GetPlayerID()
  -- Add this player to the global list so we can get them later etc...
  self.players[playerID] = player
  self.playerIncomes[playerID] = 4
  -- Set this player's starting gold
  PlayerResource:SetGold(playerID, PLAYER_STARTING_GOLD, true)
  PlayerResource:SetGold(playerID, 0, false)

  self.unitCount[playerID] = 0

  -- Search through bases to set the player's control to the correct one
  local teamIndex = 1
  for territory,totalBases in pairs(self.territories) do
    -- Update all of the bases in the territory
    for baseNumber = 1, totalBases do
      local teamNumber = self.teamNumbers[teamIndex]
      local base = Entities:FindByName(nil, territory .. " " .. baseNumber)
      
      if base:GetTeam() == heroEntity:GetTeam() then
        base:SetOwner(heroEntity)
        base:SetControllableByPlayer(playerID, true)
      end

      teamIndex = teamIndex + 1
      if teamIndex > 10 then
        teamIndex = 1
      end
    end
  end
end

-- An entity died
function GameMode:_OnEntityKilled( keys )
  -- The Unit that was Killed
  local killedUnit = EntIndexToHScript( keys.entindex_killed )
  
  if killedUnit:GetClassname() == "npc_dota_creature" then
    self.unitCount[killedUnit:GetOwner():GetPlayerID()] = self.unitCount[killedUnit:GetOwner():GetPlayerID()] - 1
    FireGameEvent('player_unit_count_changed', { teamNumber = killedUnit:GetOwner():GetTeam(), newUnitCount = self.unitCount[killedUnit:GetOwner():GetPlayerID()]})
  end

  if killedUnit:GetClassname() ~= "npc_dota_building" then
    return
  end

  print (killedUnit:GetName() .. " was killed")
  
  -- local circle = Entities:FindByName(nil, killedUnit:GetName() .. " Spawn")

  -- if circle == nil then
  --   return
  -- end

  killedUnit:RespawnUnit()

  local killerEntity = nil
  local closestDistance = 10000000
  local entitiesNearKilled = Entities:FindAllInSphere(killedUnit:GetOrigin(), 700)
  for _,unit in pairs(entitiesNearKilled) do
    if unit:GetName() == "npc_dota_creature" then
        local circleOrigin = killedUnit:GetOrigin()
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

  if killerEntity == nil then
    return
  end  

  color = TEAM_COLORS[killerEntity:GetTeam()]
  killedUnit:SetTeam(killerEntity:GetTeam())
  killedUnit:SetRenderColor(color[1], color[2], color[3])
  killedUnit:SetOwner(killerEntity:GetOwner())
  killedUnit:SetControllableByPlayer(killerEntity:GetOwner():GetPlayerID(), true)

  -- circle:SetTeam(killerEntity:GetTeam())
  -- circle:SetRenderColor(color[1], color[2], color[3])
end
