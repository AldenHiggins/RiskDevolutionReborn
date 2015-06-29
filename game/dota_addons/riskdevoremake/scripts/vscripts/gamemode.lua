-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode


-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = false 

if GameMode == nil then
    DebugPrint( '[BAREBONES] creating barebones game mode' )
    _G.GameMode = class({})
end

-- This library allow for easily delayed/timed actions
require('libraries/timers')
-- This library can be used for advancted physics/motion/collision of units.  See PhysicsReadme.txt for more information.
require('libraries/physics')
-- This library can be used for advanced 3D projectile systems.
require('libraries/projectiles')

-- These internal libraries set up barebones's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/gamemode')
require('internal/events')

-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
require('events')


--[[
  This function should be used to set up Async precache calls at the beginning of the gameplay.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).

  This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
]]
function GameMode:PostLoadPrecache()
  DebugPrint("[BAREBONES] Performing Post-Load precache")    
  --PrecacheItemByNameAsync("item_example_item", function(...) end)
  --PrecacheItemByNameAsync("example_ability", function(...) end)

  --PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
  --PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitGameMode() but needs to be done before everyone loads in.
]]
function GameMode:OnFirstPlayerLoaded()
  DebugPrint("[BAREBONES] First Player has loaded")
end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function GameMode:OnAllPlayersLoaded()
  DebugPrint("[BAREBONES] All Players have loaded into the game")
end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]
function GameMode:OnHeroInGame(hero)
  DebugPrint("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())

  -- This line for example will set the starting gold of every hero to 500 unreliable gold
  hero:SetGold(500, false)

  -- These lines will create an item and add it to the player, effectively ensuring they start with the item
  local item = CreateItem("item_example_item", hero, hero)
  hero:AddItem(item)

  --[[ --These lines if uncommented will replace the W ability of any hero that loads into the game
    --with the "example_ability" ability

  local abil = hero:GetAbilityByIndex(1)
  hero:RemoveAbility(abil:GetAbilityName())
  hero:AddAbility("example_ability")]]
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameMode:OnGameInProgress()
  DebugPrint("[BAREBONES] The game has officially begun")

  Timers:CreateTimer(30, -- Start this timer 30 game-time seconds later
    function()
      DebugPrint("This function is called 30 seconds after the game begins, and every 30 seconds thereafter")
      return 30.0 -- Rerun this timer every 30 game-time seconds 
    end)
end



-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
  GameMode = self
  DebugPrint('[BAREBONES] Starting to load Barebones gamemode...')

  -- Call the internal function to set up the rules/behaviors specified in constants.lua
  -- This also sets up event hooks for all event handlers in events.lua
  -- Check out internals/gamemode to see/modify the exact code
  GameMode:_InitGameMode()

  -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
  Convars:RegisterCommand( "command_example", Dynamic_Wrap(GameMode, 'ExampleConsoleCommand'), "A console command example", FCVAR_CHEAT )

  -- Set up territories
  self.territories = {}
  -- West Europe
  self.territories["Spain"] = 6
  self.territories["Portugal"] = 4
  self.territories["France"] = 9
  self.territories["Italy"] = 6
  self.territories["Belgium"] = 2
  self.territories["Netherlands"] = 2
  self.territories["Germany"] = 8
  self.territories["Denmark"] = 2
  -- Eastern Europe
  self.territories["Greece"] = 4
  self.territories["Albania"] = 2
  self.territories["Macedonia"] = 2
  self.territories["Montenegro"] = 2
  self.territories["Bosnia"] = 2
  self.territories["Croatia"] = 2
  self.territories["Serbia"] = 2
  self.territories["Slovenia"] = 2
  self.territories["Hungary"] = 2
  self.territories["Romania"] = 3
  self.territories["Bulgaria"] = 2
  self.territories["Ukraine"] = 7
  self.territories["Czech"] = 2
  self.territories["Moldova"] = 2
  self.territories["Slovakia"] = 2
  self.territories["Austria"] = 2
  -- North Africa/Middle East
  self.territories["Libya"] = 3
  self.territories["Egypt"] = 4
  self.territories["Israel"] = 3
  self.territories["Jordan"] = 3
  self.territories["Tunisia"] = 2
  self.territories["Algeria"] = 3
  self.territories["Morocco"] = 3
  self.territories["Turkey"] = 7
  self.territories["Lebanon"] = 2
  self.territories["Syria"] = 3
  -- Russia/CIS/Scandinavia
  self.territories["Georgia"] = 2
  self.territories["Poland"] = 5
  self.territories["Belarus"] = 4

  self.teamNumbers = {}
  self.teamNumbers[1] = 2
  self.teamNumbers[2] = 3
  self.teamNumbers[3] = 6
  self.teamNumbers[4] = 7
  self.teamNumbers[5] = 8
  self.teamNumbers[6] = 9
  self.teamNumbers[7] = 10
  self.teamNumbers[8] = 11
  self.teamNumbers[9] = 12
  self.teamNumbers[10] = 13

  self.players = {}
  self.playerIncomes = {}

  GameMode:AllocateBases()

  GameRules:GetGameModeEntity():SetThink( "IncomeCheck", self)

  DebugPrint('[BAREBONES] Done loading Barebones gamemode!\n\n')
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
      circle:SetTeam(teamNumber)
      circle:SetRenderColor(color[1], color[2], color[3])

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
  return 5
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
      territoryLabel:SetRenderColor(color[1], color[2], color[3])

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
  end
  return 60
end

-- This is an example console command
function GameMode:ExampleConsoleCommand()
  print( '******* Example Console Command ***************' )
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      -- Do something here for the player who called this command
      PlayerResource:ReplaceHeroWith(playerID, "npc_dota_hero_viper", 1000, 1000)
    end
  end

  print( '*********************************************' )
end