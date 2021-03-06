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
require('utility')


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

  -- -- This line for example will set the starting gold of every hero to 500 unreliable gold
  -- hero:SetGold(500, false)

  -- -- These lines will create an item and add it to the player, effectively ensuring they start with the item
  -- local item = CreateItem("item_example_item", hero, hero)
  -- hero:AddItem(item)

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
  -- Prevent the player from zooming in and messing up their view
  SendToConsole("dota_camera_disable_zoom 1")
  GameRules:GetGameModeEntity():SetThink( "IncomeCheck", self)
  GameRules:GetGameModeEntity():SetThink( "TimerFunction", self)
  Timers:CreateTimer(0, -- Start this timer 30 game-time seconds later
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
  self.territories["UnitedKingdom"] = 4
  self.territories["Ireland"] = 2
  -- Eastern Europe
  self.territories["Greece"] = 4
  self.territories["Bosnia"] = 2
  self.territories["Serbia"] = 2
  self.territories["Slovenia"] = 2
  self.territories["Romania"] = 3
  self.territories["Bulgaria"] = 3
  self.territories["Ukraine"] = 7
  self.territories["Czech"] = 2
  self.territories["Moldova"] = 2
  self.territories["Slovakia"] = 2
  self.territories["Austria"] = 3
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
  self.territories["Estonia"] = 3
  self.territories["Russia"] = 12
  self.territories["Finland"] = 3
  self.territories["Sweden"] = 4
  self.territories["Norway"] = 2

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
  self.unitCount = {}

  GameMode:AllocateBases()

  
  local mode = GameRules:GetGameModeEntity()
  -- Disables hero hud
  mode:SetHUDVisible(1, false)
  -- Disables shop
  --mode:SetHUDVisible(6, false)

  print ("registering command")
  Convars:RegisterCommand( "ExampleCommand", function(name, p)
      --get the player that sent the command
      local cmdPlayer = Convars:GetCommandClient()
      if cmdPlayer then 
          --if the player is valid, execute PlayerBuyAbilityPoint
          return self:ExampleFunction( cmdPlayer, p ) 
      end
  end, "A player buys an ability point", 0 )
  print ("done registering command")
  DebugPrint('[BAREBONES] Done loading Barebones gamemode!\n\n')



  -- Also can be used to create fake players
  Convars:RegisterCommand('fake', function()
      print ("Fake command used")
      -- Check if the server ran it
      if Convars:GetCommandClient() then
        print ("This is happening")
        -- Create fake Players
        SendToServerConsole('dota_create_fake_clients')

        local userID = 20
        print("Timer function called")
        for i=0, 9 do
          userID = userID + 1
          print ("Checking id: ", userID)
          -- Check if this player is a fake one
          if PlayerResource:IsFakeClient(i) then
            print ("Player is fake client")
              -- Grab player instance
            local ply = PlayerResource:GetPlayer(i)
            ply:SetTeam(self.teamNumbers[i + 1])
              -- Make sure we actually found a player instance
            if ply then
              print ("Got the player to make a hero for")
              CreateHeroForPlayer('npc_dota_hero_axe', ply)
              self:OnConnectFull({ userid = userID, index = ply:entindex()-1 })
              ply:GetAssignedHero():SetControllableByPlayer(0, true)
            end
          end
        end
      end
  end, 'Connects and assigns fake Players.', 0)

  -- Also can be used to create fake players
  Convars:RegisterCommand('disconnectBot', function()
      print ("Disconnecting player...")
      local playerToDisconnect = PlayerResource:GetPlayer(3)
      playerToDisconnect:Kill()
  end, 'Disconnect a player', 0)

  
end

function GameMode:ExampleFunction (playerPerformedCommand, p)
  print ("The button was clicked!!!")
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