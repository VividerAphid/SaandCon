require("mod_common_utils")
require("mod_elo")
require("mod_playerData")
require("mod_wintracker")
require("configs")
require("utils")
require("censorList")
require("admins")
require("lobbyCommands")
require("html")
require("stages")
require("mapkit")
require("bot_utils")

LICENSE = [[
mod_server.lua

Copyright (c) 2013 Phil Hassey
Modifed by: Tycho2 and VividerAphid

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Galcon is a registered trademark of Phil Hassey
For more information see http://www.galcon.com/
]]
--------------------------------------------------------------------------------
strict(true)
if g2.headless == nil then
    require("mod_client") -- HACK: not a clean import, but it works
end
--------------------------------------------------------------------------------
function menu_init()
    GAME.modules.menu = GAME.modules.menu or {}
    local obj = GAME.modules.menu
    local _CONFIGS = loadConfigs()
    function obj:init()
        g2.html = startupMenu()
        GAME.data = json.decode(g2.data)
        if type(GAME.data) ~= "table" then GAME.data = {} end
        if GAME.data.wipeKeyWord == nil or GAME.data.wipeKeyWord ~= _CONFIGS.wipeKeyWord then
            print("Data Wiped per configs keyword mismatch!")
            g2.data = json.encode({})
            GAME.data = json.decode(g2.data)
            GAME.data.wipeKeyWord = _CONFIGS.wipeKeyWord
            g2.data = json.encode(GAME.data)
            GAME.data = json.decode(g2.data)
            playerData.wipeAllData()
            playerWinData.wipeAllData()
            elo.clear_ratings()
        end
        g2.form.port = GAME.data.port or "23099"
        g2.form.title = GAME.data.title or "SaandCon"
        g2.state = "menu"
        g2.chat_keywords(json.encode(_CONFIGS.chat_keywords))
        GAME.galcon.wins = 0
        GAME.galcon.scorecard = {}
        GAME.galcon.gamemode = "Classic" or "Stages" or "Frenzy" or "Grid" or "Float" or "Line" or "Race"
        GAME.galcon.tournament = false
        GAME.galcon.setmode = false
        GAME.galcon.global = {
            CONFIGS = _CONFIGS,
            WINNER_STAYS = _CONFIGS.defaults.WINNER_STAYS,
            PLAYER_QUEUE = {},
            BOTS = {},
            BOT_TYPES = {punchingbag={func=punchingbag_bot,uid=-1, displayName="Punching Bag"}, protowaffle={func=bot_protowaffle, uid=-3, displayName="Protowaffle"}, classic={func=bot_classic, uid=-2, displayName="Classic"}},
            BOT_UID = -10000,
            BOT_COUNT = 0,
            MAX_BOT_COUNT = _CONFIGS.defaults.MAX_BOT_COUNT,
            MAX_PLAYERS = _CONFIGS.defaults.MAX_PLAYERS,
            SOLO_MODE = false, --for if someone wants to play a solo game like grid or something
            MAP_STYLE = _CONFIGS.defaults.MAP_STYLE,
            SAANDBUFF_DATA = _CONFIGS.defaults.SAANDBUFF_DATA, --See configs
            TIMER_LENGTH = _CONFIGS.defaults.TIMER_LENGTH,
            STARTING_SHIPS = _CONFIGS.defaults.STARTING_SHIPS,
            HOME_COUNT = _CONFIGS.defaults.HOME_COUNT,
            HOME_PROD = _CONFIGS.defaults.HOME_PROD,
            GRID = _CONFIGS.defaults.GRID,
            SEED_DATA = _CONFIGS.defaults.SEED_DATA,
            stupidSettings = _CONFIGS.defaults.stupidSettings,
            matchXp = 0,
            ships=buildShipList(),
            planets= {'normal','honeycomb','ice','terrestrial','gasgiant','craters','gaseous','lava', 'void', 'disco','swirls','floralpattern',
                'hearts', 'clovers', 'zerba', 'giraffe', 'eyes', 'cow', 'fossil', 'snowcaps', 'smooth', 
                'whisp', 'charlie', 'snowflake', 'candycane', 'snowglobe',
                normal={normal=true,lighting=true,texture="tex0"},
                honeycomb={lighting=true,texture="tex13",normal=true},
                ice={ambient=true,texture="tex3",drawback=true,alpha=.65,addition=true,lighting=true},
                terrestrial={overdraw={addition=true,alpha=.5,reflection=true,texture="tex7w"},normal=true,lighting=true,texture="tex7"},
                gasgiant={overdraw={texture="tex1",yaxis=true,alpha=.25,addition=true,lighting=true},normal=true,lighting=true,texture="tex9"},
                craters={texture="tex12",normal=true,lighting=true,overdraw={texture="tex12b",yaxis=true,lighting=true,alpha=1,addition=true}},
                gaseous={overdraw={texture="tex2",yaxis=true,addition=true,lighting=true},normal=true,lighting=true,texture="tex2"},
                lava={overdraw={ambient=true,addition=true,texture="tex5"},normal=true,lighting=true,texture="tex0"},
                disco={overdraw={ambient=true,addition=true,yaxis=true,texture="dis2"},normal=true,lighting=true,texture="dis1"},
                floralpattern={normal=false,lighting=false,texture="tex19"},
                swirls={normal=true,lighting=true,texture="tex16"},
                snowcaps={normal=true,lighting=true,texture="tex15"},
                clovers={normal=true,lighting=true, texture="tex18"},
                hearts={normal=true,lighting=true,texture="tex17"},
                zerba={normal=true,lighting=true,texture="texs1"},
                giraffe={normal=true,lighting=true,texture="texs2"},
                eyes={normal=true,lighting=true,texture="texs3"},
                cow={normal=true,lighting=true,texture="texw1"},
                fossil={normal=true,lighting=true,texture="texw2"},
                smooth={normal=false,lighting=false,texture="tex6"},
                whisp={overdraw={texture="tex12b",yaxis=true,addition=true,lighting=true},normal=true,lighting=true,texture="tex12b"},
                charlie={normal=true,lighting=true,texture="dec1"},
                snowflake={normal=true,lighting=true,texture="dec2"},
                candycane={normal=true,lighting=true,texture="dec3"},
                snowglobe={overdraw={texture="dec4",alpha=1.5,drawback=true,yaxis=true,addition=false,lighting=false},normal=true,lighting=true,texture="dec4"},
            },
        }
    end
    function obj:loop(t)
    end
    function obj:event(e)
        if e.type == 'onclick' and e.value == 'host' then
            GAME.data.port = g2.form.port
            GAME.data.title = g2.form.title
            g2.data = json.encode(GAME.data)
            g2.net_host(GAME.data.port)
            GAME.engine:next(GAME.modules.lobby)
            if g2.headless == nil then
                g2.net_join("",GAME.data.port)
            end
        end
    end
end
--------------------------------------------------------------------------------
function set_spectator_mode(client)
    if client == nil then return end

    if (client.status == "queue" or client.status == "away") and GAME.galcon.gamemode ~= "Stages" then
        local spectator = g2.new_user(client.name, client.color)
        spectator.user_uid = client.uid
        spectator.ui_ships_show_mask = 0xF
        spectator.user_neutral = 1
    end
end
function clients_queue(e)
    _clients_queue()
    resetLobbyHtml(e)
end
function _clients_queue()
    local colors = {
        '0x0000ff','0xff0000',
        '0xffff00','0x00ffff',
        '0xffffff','0xff8800',
        '0x99ff99','0xff9999',
        '0xbb00ff','0xff88ff',
        '0x9999ff','0x00ff00',
    }
    -- delete colors above MAX_PLAYERS treshold
    -- for i, v in pairs(colors) do
    --     if (i > GAME.galcon.global.MAX_PLAYERS) then
    --         colors[i] = nil
    --     end
    -- end

    local q = nil
    for k,e in pairs(GAME.clients) do
        -- set color of "away" and "queue" players to grey
        if e.status == "away" or e.status == "queue" then
            e.color = '0x555555'
        end
        if e.status == "queue" then 
            q = e 
        end

        -- set color of players in "play" to nil
        for i,v in pairs(colors) do
            if v == e.color then colors[i] = nil end
        end
    end

    -- if there are no players in "queue" return
    if q == nil then 
        return 
    end

    -- assign a color to players in "queue" and set their status to "play"
    for i,v in pairs(colors) do
        if v ~= nil then
            if(q.colorData ~= nil) then
                q.color = q.colorData
                editPlayerData("color", q.uid, q.color)
            else
                q.color = colors[math.random(1, #colors)]
                if(tonumber(q.uid) > 0) then
                    editPlayerData("color", q.uid, q.color)
                else
                    q.color = rollRandColor()
                end
            end
            q.status = "play"
            net_send("","message",q.displayName .. " is /play")
            return
        end
    end
end

function clients_init()
    GAME.modules.clients = GAME.modules.clients or {}
    GAME.clients = GAME.clients or {}
    local obj = GAME.modules.clients
    function obj:event(e)
        if e.type == 'net:join' then
            playerData_init()
            local newCoins = GAME.galcon.global.CONFIGS.saandCoins.newPlayerSaandCoins
            local incomingPlayerData = {uid=e.uid,displayName=e.name, name=e.name, ship="ship",skin="normal",status="away", 
                    title="", colorData=nil, coins=newCoins, ownedShips={"ship"}, ownedSkins={"normal"}, stats=getNewStatTable()}
            if playerData.getUserData(e.uid) == nil then
                if(tonumber(e.uid) < 0) then
                    incomingPlayerData.skin = getNewBotSkin()
                    incomingPlayerData.ship = getNewBotShip()
                    incomingPlayerData.botID = GAME.galcon.global.BOT_TYPES[e.bot].uid
                    incomingPlayerData.botName = e.bot
                    if(playerData.getUserData(e.bot) == nil) then
                        print("New bot record")
                        local id = e.bot
                        playerData.InitNewPlayer(id)
                        playerData.setPlayerDisplayName(id, "BOT-"..GAME.galcon.global.BOT_TYPES[e.bot].displayName)
                        playerData.setPlayerColor(id, rollRandColor())
                        playerData.setPlayerStats(id, getNewStatTable())
                        playerData.setPlayerLevel(id, 0)
                        playerData.setPlayerXP(id, 0)
                        playerData.setPlayerPrestige(id, 0)
                        playerData.setPlayerQuote(id, "I'm a bot")
                        playerData.saveData()
                        
                        playerWinData.initNewWinData(id)
                        playerWinData.saveData()
                    end
                else
                    playerData.InitNewPlayer(e.uid)
                    playerData.setPlayerCoins(e.uid, newCoins)
                    playerData.setPlayerDisplayName(e.uid, e.name)
                    playerData.setPlayerStats(e.uid, getNewStatTable())
                    playerData.setPlayerLevel(e.uid, 0)
                    playerData.setPlayerXP(e.uid, 0)
                    playerData.setPlayerPrestige(e.uid, 0)
                    playerData.saveData()

                    playerWinData.initNewWinData(e.uid)
                    playerWinData.saveData()
                end
            else
                --playerData.clearPlayerEntry(e.uid)
                --playerData.wipeAllData()
                --playerData.saveData()
                local datPack = playerData.getUserData(e.uid)
                incomingPlayerData.displayName = datPack.displayName
                incomingPlayerData.ship = datPack.ship
                incomingPlayerData.skin = datPack.skin
                incomingPlayerData.title = datPack.title
                incomingPlayerData.quote = datPack.quote
                incomingPlayerData.colorData = datPack.color
                incomingPlayerData.coins = datPack.coins
                incomingPlayerData.ownedShips = datPack.ownedShips
                incomingPlayerData.ownedSkins = datPack.ownedSkins
                incomingPlayerData.stats = datPack.stats or getNewStatTable()
            end
            if amountOfPlay() < GAME.galcon.global.MAX_PLAYERS then
                incomingPlayerData.status = "queue"
            else
                incomingPlayerData.status = "away"
            end
            GAME.clients[e.uid] = incomingPlayerData
            keywords_addKeyword(e.name)
            keywords_addKeyword(GAME.clients[e.uid].displayName)
            keywords_refreshKeywords()
            set_spectator_mode(GAME.clients[e.uid])
            clients_queue(e)
            net_send("","message",GAME.clients[e.uid].displayName .. " joined")
            g2.net_send("","sound","sfx-join");
            if tonumber(GAME.galcon.scorecard[e.uid]) == nil then
                --print("e.uid: " ..e.uid)
                GAME.galcon.scorecard[e.uid] = GAME.galcon.wins
            end
        end
        if e.type == 'net:leave' then
            --print("called from first net:leave")
            local player = playerData.getUserData(botUidFix(e))
            net_send("","message",player.displayName .. " left")
            GAME.clients[e.uid] = nil
            g2.net_send("","sound","sfx-leave");
            clients_queue(e)
        end
        if e.type == 'net:message' then
            handleNetMessage(e)
        end
        
        if isNetMessageOrButton(e) then
            if matchesCommand(e.value, "elo") then
                local uid = getEventUid(e)
                -- TODO: this doesn't work for ME
                net_send(uid, "message", "Your elo is " .. common_utils.round(elo.get_elo(e.name)))
            end
            if matchesCommand(e.value, "matchup") then
                local uid = getEventUid(e)
                local commandParts = searchString(e.value, "%S+")

                if #commandParts ~= 3 then 
                    net_send(uid, "message", "(Server -> "..e.name..") Error: Malformed command.")
                else 
                    local player1Name = commandParts[2]
                    local player2Name = commandParts[3]
                    local winPercent = elo.player_win_probability(player1Name, player2Name)
                    if winPercent ~= nil then
                        local prettyPercent = common_utils.round(winPercent * 100)
                        net_send(uid, "message", "The predicted win rate for " .. player1Name .. " vs. " .. player2Name .. " is " .. prettyPercent .. "%")
                    end
                end
            end
        end

    end
end

function matchesCommand(string, searchCommand)
    if string == nil then
        return false
    end
    local justCommand = searchString(string, "%S+")[1]
    if justCommand == nil then
        return false
    end
    if justCommand == "." .. searchCommand or justCommand == "/" .. searchCommand then
        return true
    end
    -- single letter commands don't need the . or /
    if justCommand:len() == 1 and justCommand == searchCommand then
        return true
    end
    return false
end

function limitColor(color)
    local r1, r2, g1, g2, b1, b2
    local darkCounter = 0

    r1 = string.sub(color,3,3)
    r1 = stringToNumber(r1)
    r1 = tonumber(r1)
    r2 = string.sub(color,4,4)
    r2 = stringToNumber(r2)
    r2 = tonumber(r2)

    g1 = string.sub(color,5,5)
    g1 = stringToNumber(g1)
    g1 = tonumber(g1)
    g2 = string.sub(color,6,6)
    g2 = stringToNumber(g2)
    g2 = tonumber(g2)

    b1 = string.sub(color,7,7)
    b1 = stringToNumber(b1)
    b1 = tonumber(b1)
    b2 = string.sub(color,8,8)
    b2 = stringToNumber(b2)
    b2 = tonumber(b2)
    
    if r1 == nil or r2 == nil or g1 == nil or g2 == nil or b1 == nil or b2 == nil then color = "0000000" end

    if r1 ~= nil and r2 ~= nil then
        if r1*r2 < 75 then
            darkCounter = darkCounter + 1
            --print("R: "..r1*r2)
        end
    end
    if g1 ~= nil and g2 ~= nil then
        if g1*g2 < 75 then
            darkCounter = darkCounter + 1
            --print("G: "..g1*g2)
        end
    end
    if b1 ~= nil and b2 ~= nil then
        if b1*b2 < 75 and b1 then 
            darkCounter = darkCounter + 1
        -- print("B "..b1*b2)
        end
    end
    --print(darkCounter)
    if darkCounter == 3 then
        color = "000000"
    end
    return color
end

function limitColorNew(color)
    color = color:gsub("^0x", "")
    
    if #color ~= 6 then
      error("Invalid hex code: " .. color, 2)
    end
    
    local red   = tonumber(color:sub(1, 2), 16)
    local green = tonumber(color:sub(3, 4), 16)
    local blue  = tonumber(color:sub(5, 6), 16)
    
    if (red + green + blue) * 0.33333333333 < 69 then
      return "0000000"
    else
      return color
    end
end

function darkenColor(color)
    local red = tonumber(string.sub(color, 3,4), 16)
    local green = tonumber(string.sub(color, 5,6), 16)
    local blue = tonumber(string.sub(color, 7,8), 16)
    local darknessRatio = .85

    red = string.format("%x", math.floor(red * darknessRatio))
    green = string.format("%x", math.floor(green * darknessRatio))
    blue = string.format("%x", math.floor(blue * darknessRatio))

    if(tonumber(red, 16) < 16) then 
        red = "0"..red
    end
    if(tonumber(green, 16) < 16) then 
        green = "0"..green
    end
    if(tonumber(blue, 16) < 16) then 
        blue = "0"..blue
    end

    return "0x"..red..green..blue
end

--------------------------------------------------------------------------------
function params_set(k,v)
    GAME.params[k] = v
    net_send("",k,v)
end
function params_init()
    GAME.modules.params = GAME.modules.params or {}
    GAME.params = GAME.params or {}
    GAME.params.state = GAME.params.state or "lobby"
    GAME.params.html = GAME.params.html or ""
    local obj = GAME.modules.params
    function obj:event(e)
        if e.type == 'net:join' then
            net_send(e.uid,"state",GAME.params.state)
            net_send(e.uid,"html",GAME.params.html)
            net_send(e.uid,"tabs",GAME.params.tabs)
        end
    end
end
--------------------------------------------------------------------------------
function chat_init()
    GAME.modules.chat = GAME.modules.chat or {}
    GAME.clients = GAME.clients or {}
    local obj = GAME.modules.chat
    function obj:event(e)
        if e.type == 'net:message' and not isEmptyOrSlash(e.value) then
            if GAME.galcon.global.stupidSettings.yodaFilter and string.lower(GAME.clients[e.uid].name) == "master_yoda_" then
                net_send("","chat",json.encode({uid=e.uid,color=GAME.clients[e.uid].color,value="<"..GAME.clients[e.uid].name.."> ".."GG WP"}))
            else
                net_send("","chat",json.encode({uid=e.uid,color=GAME.clients[e.uid].color,value="<"..GAME.clients[e.uid].name.."> "..e.value}))       
            end     
        end
    end
end
function isEmptyOrSlash(s)
    return s == nil or s:match("%S") == nil or string.sub(s,1,1) == "/"
end
function getAllColors()
    return "blue red green yellow cyan purple white orange pink mint periwinkle salmon"
end
--------------------------------------------------------------------------------
function lobby_init()
    GAME.modules.lobby = GAME.modules.lobby or {}
    local obj = GAME.modules.lobby
    function obj:init()
        g2.state = "lobby"
        self.startTimerLength = 3
        self.startTimer = 1000
        self.isStarted = false
        self.isSend = false
        params_set("state","lobby")
        resetLobbyHtml()
    end
    
    function obj:loop(t)
        --print(dump(GAME.clients))
        --net_send('',"message","TIME OUT")
        self.startTimer = self.startTimer + t

        if self.startTimer >= 0 and self.startTimer < self.startTimerLength then
            if math.floor(self.startTimer) >= self.countDown then
                play_sound("sfx-getready")
                net_send("", "message", ">> T-minus " .. (3 - self.countDown) .. " <<")
                self.countDown = self.countDown + 1
            end
        end

        if self.startTimer >= self.startTimerLength and self.startTimer < 1000 then
            GAME.engine:next(GAME.modules.galcon)
        end
    end
    function obj:event(e)
        if e.type == 'net:message' and string.lower(e.value) == '/start' or e.type == 'onclick' and e.value == '/start' then
            if self.isStarted == false and (#playersWithStatus("play") <= GAME.galcon.global.MAX_PLAYERS) then
                if e.name == nil then
                    net_send("","message",GAME.clients[g2.uid].displayName.." /start")
                else
                    net_send("","message",GAME.clients[e.uid].displayName.." /start")
                end
                self.startTimer = 0
                self.countDown = 0
                self.isStarted = true
                self.isSend = true
            elseif self.isSend == false then
                net_send("","message", "Player limit: "..GAME.galcon.global.MAX_PLAYERS)
                self.isSend = true
            end
        end
        if e.type == 'onclick' then
            handleOnclick(e)
        end
    end
end
function amountOfPlay()
    local playState = {}
    for k,e in pairs(GAME.clients) do
        if e.status == "play" then
            table.insert(playState, e)
        end
    end
    return #playState
end
--------------------------------------------------------------------------------
function galcon_classic_init()
    GAME.galcon.float = {}
    local OPTS = {
        neutrals = 25,
        first_neutrals = 12,
        second_neutrals = 18,
        sw = 520,
        sh = 360,
    }
    
    local G = GAME.galcon
    g2.game_reset();
    
    local seed = os.time() -- + 1616606700
    local seedstring = GAME.galcon.global.SEED_DATA.SEED_STRING
    GAME.galcon.global.SEED_DATA.PREV_SEED_STRING = GAME.galcon.global.SEED_DATA.SEED_STRING
    if GAME.galcon.global.SEED_DATA.CUSTOMISED then
        seed = GAME.galcon.global.SEED_DATA.SEED
        if GAME.galcon.global.SEED_DATA.KEEP_SEED == false then
            GAME.galcon.global.SEED_DATA.CUSTOMISED = false
            GAME.galcon.global.SEED_DATA.SEED_STRING = nil
        end
    else
        GAME.galcon.global.SEED_DATA.SEED_STRING = nil
    end
    GAME.galcon.global.SEED_DATA.PREV_SEED = (seed % 1616606700)
    math.randomseed(seed % 1616606700)
    G.time = 0
    g2.state = "play"

    local o = g2.new_user("neutral",0x555555)
    o.user_neutral = 1
    o.ships_production_enabled = 0
    G.neutral = o
    
    if GAME.galcon.gamemode == "Stages" then
        G.neutral_hide = g2.new_user("neutral",0x555555)
        G.neutral_hide.user_neutral = 0
        G.neutral_hide.ships_production_enabled = 0
        G.neutral_hide.planet_crash = 2
        G.neutral_hide.ui_to_mask = 0x4
    end

    if GAME.galcon.gamemode == "Stages" then
        G.neutral_hide2 = g2.new_user("neutral",0x555555)
        G.neutral_hide2.user_neutral = 0
        G.neutral_hide2.ships_production_enabled = 0
        G.neutral_hide2.planet_crash = 2
        G.neutral_hide2.ui_to_mask = 0x4
    end
    
    
    g2.bkgr_src = "black"

    local users = {}
    G.users = users
    local playcount = 0
    local modIds = {saandId=-1, aphidId=-1}--temporary for saandbuff

    for uid,client in pairs(GAME.clients) do
        if string.lower(client.name) == "binah." then
            modIds.saandId = client.uid
        elseif string.lower(client.name) == "hostaphid" then
            modIds.aphidId = client.uid
            --print(modIds.aphidId)
        end
        if client.status == "play" then
            playcount = playcount+1
            local p = g2.new_user(client.name,client.color)
            users[#users+1] = p
            p.user_uid = client.uid
            p.fleet_image = client.ship
            p.planet_style = json.encode(GAME.galcon.global.planets[client.skin])
            if GAME.galcon.gamemode == "Race" then
                p.planet_crash = 2
            end
            client.inGame = true
            if tonumber(p.user_uid) < 0 then --see if the player is a bot and set up bot stuff
                local b = GAME.galcon.global.BOTS[client.uid]
                --print(b.bot)
                --print(GAME.galcon.global.BOT_TYPES[b.bot])
                --print(GAME.galcon.global.BOT_TYPES[b.bot].uid)
                b.run = GAME.galcon.global.BOT_TYPES[b.bot].func(p)
            end
        end
        -- Let spectators see planet ship counts.
        set_spectator_mode(client)
    end
    if playcount > 1 and GAME.galcon.global.SOLO_MODE then
        net_send('',"message","Solo mode disabled due to multiple players!")
        GAME.galcon.global.SOLO_MODE = false
    end
    local sw = OPTS.sw -- ELIM RATIO 560x360 -- Saand ratio 520x360
    local sh = OPTS.sh 

    local pad = 0
    if GAME.galcon.gamemode == "Stages" then
        g2.view_set(0, 0, sw, sh)
        local planets = {}

        local home_production, home_ships = 100, GAME.galcon.global.STARTING_SHIPS
        local home_r = prodToRadius(home_production)

        local a = math.random(0,360)
        for i,user in pairs(users) do
            if GAME.galcon.gamemode == "Stages" then
                local x,y
                local x = sw/2 + (sw-pad*2)*math.cos(a*math.pi/180.0)/2.0
                local y = sh/2 + (sh-sh/15*2)*math.sin(a*math.pi/180.0)/2.0

                G.home = g2.new_planet(user, x, y, home_production, home_ships);
                a = a + 360/#users

                local planetHome = {}

                planetHome.x = x
                planetHome.y = y
                planetHome.r = home_r

                local planetHomeSym = {}

                planetHomeSym.x = sw - x
                planetHomeSym.y = sh - y
                planetHomeSym.r = home_r

                table.insert(planets, planetHome)
                table.insert(planets, planetHomeSym)
            end
        end

        for i=1, OPTS.neutrals/2 do 
            local prod = math.random(35,100)
            local radius = prodToRadius(prod)
            local x = math.random(radius, sw - radius)
            local y = math.random(radius, sh - radius)
            local neutrals_cost = math.random(5,35)

            local attempts = 0
            local margin = prodToRadius(30)

            if #planets > 1 then
                local didCollide = true
                while didCollide and attempts < 500 do
                    didCollide = false
                    if getDistance(x, y, sw/2, sh/2) <= radius + margin then
                        x = math.random(radius, sw - radius)
                        y = math.random(radius, sh - radius)
                        didCollide = true
                        attempts = attempts + 1
                    end
                    for j=1, #planets do
                        if getDistance(x, y, planets[j].x, planets[j].y) <= radius + planets[j].r + margin and
                        getDistance(x, y, planets[j].x, planets[j].y) ~= 0 then
                            x = math.random(radius, sw - radius)
                            y = math.random(radius, sh - radius)
                            didCollide = true
                            attempts = attempts + 1
                            break
                        end 
                    end
                end
            end

            if i <= OPTS.first_neutrals/2 then
                g2.new_planet(o, x, y, prod, neutrals_cost-4);
                g2.new_planet(o, sw-x, sh-y, prod, neutrals_cost-4);
            elseif i > OPTS.first_neutrals/2 and i <= OPTS.second_neutrals/2 then
                g2.new_planet(G.neutral_hide, x, y, prod, neutrals_cost);
                g2.new_planet(G.neutral_hide, sw-x, sh-y, prod, neutrals_cost);
            else
                g2.new_planet(G.neutral_hide2, x, y, prod, neutrals_cost);
                g2.new_planet(G.neutral_hide2, sw-x, sh-y, prod, neutrals_cost);
            end

            local planet = {}
            planet.x = x
            planet.y = y
            planet.r = radius
            planet.cost = cost
            planet.prod = prod
            
            local planetSym = {}
            planetSym.x = sw - x
            planetSym.y = sh - y
            planetSym.r = radius
            planetSym.cost = cost
            planetSym.prod = prod

            table.insert(planets, planet)
            table.insert(planets, planetSym)

        end
    end
    

    if GAME.galcon.gamemode == "Classic" then
        
        local numMapStyles = 6
        --local mapStyle = 3 -- MIX: getMapStyle(numMapStyles) // Classic: 0 // PhilBuff: 1 // 12p: 2 // Saandbuff: 3 // wonk: 4 // expand(1 ship mode): 5
        local mapStyle = -1
        if(GAME.galcon.global.MAP_STYLE == "mix") then
            mapStyle = getMapStyle(numMapStyles)            
        else
            mapStyle = GAME.galcon.global.MAP_STYLE
            --print(mapStyle)
        end

        if mapStyle == 0 then
            sw = sw / 1.1
            sh = sh / 1.1
        end
        if mapStyle == 2 then
            sw = sw / 1.25
            sh = sh / 1.25
            OPTS.neutrals = OPTS.neutrals / 2
        end
        if mapStyle == 5 then
            sw = sw / 1.25
            sh = sh / 1.25
        end
        g2.view_set(0, 0, sw, sh)

        local planets = {}

        local home_production, home_ships = GAME.galcon.global.HOME_PROD, GAME.galcon.global.STARTING_SHIPS
        local home_r = prodToRadius(home_production)
        
        if mapStyle == 4 then
            home_production = math.floor(math.random(1, 100))
            home_ships = math.floor(math.random(1, 100))
            home_r = prodToRadius(home_production)
        elseif mapStyle == 5 then
            home_production = 10
            home_ships = 1
            home_r = prodToRadius(50)
	    end

        local a = math.random(0,360)
        --local homeCoords = {0,0}
        for i=1, GAME.galcon.global.HOME_COUNT do
            for i,user in pairs(users) do
                local x,y
                local x = sw/2 + (sw-pad*2)*math.cos(a*math.pi/180.0)/2.0
                local y = sh/2 + (sh-sh/15*2)*math.sin(a*math.pi/180.0)/2.0
    
                G.home = g2.new_planet(user, x, y, home_production, home_ships);
                G.home.planet_r = home_r
                a = a + 360/#users
    
                local planetHome = {}
    
                planetHome.x = x
                planetHome.y = y
                planetHome.r = home_r
    
                local planetHomeSym = {}
    
                planetHomeSym.x = sw - x
                planetHomeSym.y = sh - y
                planetHomeSym.r = home_r
    
                table.insert(planets, planetHome)
                table.insert(planets, planetHomeSym)
                --homeCoords[0] = x
                --homeCoords[1] = y
            end
            a = math.random(0,360)
        end
        
        local sb_versions = GAME.galcon.global.SAANDBUFF_DATA.VERSIONS_ENABLED
        local enabled = {}
        local distOn = GAME.galcon.global.SAANDBUFF_DATA.DISTANCE_ENABLED
        --select all enabled versions of saandbuff
        for i=1, #sb_versions do
            if sb_versions[i] == true then
                enabled[#enabled+1] = i
            end
        end
        local SBEnabledCount = #enabled
        local stylePick = -1
        if SBEnabledCount == 0 then
            stylePick = math.random(1, #sb_versions)
        else
            stylePick = enabled[math.random(1,SBEnabledCount)]
        end
        local picked = "V" .. stylePick --SaandBuff
        local prodMin = 30
        local prodMax = 100

        local count = OPTS.neutrals/2
        for i=1, count do
            local prod = 0
            if mapStyle == 3 and distOn == false then
                if stylePick == 4 then
                    prod = math.random(20, 120)
                elseif stylePick == 5 then
                    prod = math.random(20, 110)
                elseif stylePick == 6 then
                    prod = math.random(20, 120)
                elseif stylePick == 7 then
                    prod = math.random(30, 120)
                elseif stylePick == 8 then
                    prod = math.random(20, 120)
                elseif stylePick == 9 then
                    prod = math.random(15, 80)
                elseif stylePick == 10 then
                    prod = math.random(15, 90)
                else
                    prod = math.random(prodMin, prodMax)
                end
            elseif mapStyle == 4 then
                prod = math.floor(math.random(1, 100))
            elseif mapStyle == 5 then
                prod = 10
            else 
                prod = math.random(prodMin, prodMax)
            end
            local radius = prodToRadius(prod)
            local x = math.random(radius, sw - radius)
            local y = math.random(radius, sh - radius)
            if mapStyle == 3 and distOn then
                local maxDistance = getDistance(homeCoords[0], homeCoords[1], sw-homeCoords[0], sh-homeCoords[1])/2
                local distance = getDistance(x, y, homeCoords[0], homeCoords[1])
                local distanceSym = getDistance(x, y, sw-homeCoords[0], sh-homeCoords[1])
                local pickedDist = 0
                print("d ".. math.floor(distance) .. " v dS " .. math.floor(distanceSym))
                if(distance > distanceSym) then
                    pickedDist = distanceSym
                    print("distsym "..i.. " = "..math.floor(distanceSym))
                else
                    print("dist "..i.. " = "..math.floor(distance))
                    pickedDist = distance
                end
                prod = getSaandDistProd(version, pickedDist, maxDistance)
                radius = prodToRadius(prod)
            end
            if mapStyle == 5 then
                radius = prodToRadius(35)
            end
            local cost = 0
            if mapStyle == 0 then
                cost = math.floor(math.random(0,30))
            elseif mapStyle == 1 then
                cost = math.floor(math.random(prod / 20, prod / 1.50))--math.floor(math.random(prod / 10, prod / 1.75))
            elseif mapStyle == 2 then
                cost = math.floor(math.random(0,20))
            elseif mapStyle == 3 then
                if distOn then
                    cost = getSaandDistCost(stylePick, i)
                else
                    cost = getSaandbuffVals(stylePick, prod)
                end
            elseif mapStyle == 4 then
            	local costRatio = math.floor(home_ships * .5)
            	cost = math.floor(math.random(0, costRatio))
            elseif mapStyle == 5 then
                cost = 0
            elseif mapStyle > numMapStyles then
                print("Error: mapStyle out of range ("..mapStyle..')')
            end
            local attempts = 0
            local margin = prodToRadius(30)

            if #planets > 1 then
                local didCollide = true
                while didCollide and attempts < 500 do
                    didCollide = false
                    if getDistance(x, y, sw/2, sh/2) <= radius + margin then
                        x = math.random(radius, sw - radius)
                        y = math.random(radius, sh - radius)
                        didCollide = true
                        attempts = attempts + 1
                    end
                    for j=1, #planets do
                        if getDistance(x, y, planets[j].x, planets[j].y) <= radius + planets[j].r + margin and
                        getDistance(x, y, planets[j].x, planets[j].y) ~= 0 then
                            x = math.random(radius, sw - radius)
                            y = math.random(radius, sh - radius)
                            didCollide = true
                            attempts = attempts + 1
                            break
                        end 
                    end
                end
            end

            local plan = g2.new_planet(o, x, y, prod, cost)
            local planSym = g2.new_planet(o, sw - x, sh - y, prod, cost)
            plan.planet_r = radius
            planSym.planet_r = radius

            local planet = {}
            planet.x = x
            planet.y = y
            planet.r = radius
            planet.cost = cost
            planet.prod = prod
            
            local planetSym = {}
            planetSym.x = sw - x
            planetSym.y = sh - y
            planetSym.r = radius
            planetSym.cost = cost
            planetSym.prod = prod

            table.insert(planets, planet)
            table.insert(planets, planetSym)
        end
        if mapStyle == 3 then
            -- if modIds.saandId ~= -1 then
            --     net_send(modIds.saandId, "message", picked)
            -- end
            -- if modIds.aphidId ~= -1 then
            --     net_send(modIds.aphidId, "message", picked)
            -- end
            net_send("", "message", picked)
        end
    end

    if GAME.galcon.gamemode == "Grid" then
        OPTS.sw = sw
        OPTS.sh = sh
        
        sw = sw/1.25
        sh = sh/1.25

        local planets = {}
        local mixed = false --For when we want random map style
        if GAME.galcon.gametype == "Mix" then
            mixed = true
            local options = {"Standard", "Hexagon", "Donut"}
            local pick = math.random(#options)
            GAME.galcon.gametype = options[pick]
        end
        for i=0, math.sqrt(OPTS.neutrals)-1 do
            for j=0, math.sqrt(OPTS.neutrals)-1 do
            local x, y
            local neutrals_production = GAME.galcon.global.GRID.NEUT_PROD
            local neutrals_cost = GAME.galcon.global.GRID.NEUT_COST

            x = sh/(OPTS.neutrals-1)*i*(math.sqrt(OPTS.neutrals)+1)
            y = sh/(OPTS.neutrals-1)*j*(math.sqrt(OPTS.neutrals)+1)

            local planet = g2.new_planet(o, x, y, neutrals_production, neutrals_cost);
            
            table.insert(planets, planet)
            end
        end

        local spawns = {1, 2, 3, 4, 5, 6, 10, 11}
        local home = spawns[math.random(#spawns)]
        local home_prod = GAME.galcon.global.GRID.HOME_PROD

        -- while home == (#planets+1)/2 do
        --     home = math.random(1, #planets)
        -- end
        if GAME.galcon.gametype == "Hexagon" and amountOfPlay() == 1 then
            home = 13
        end
        if GAME.galcon.gametype == "Hexagon" and amountOfPlay() ~= 1 then
            while home == 1 or home == 21 or home == 22 or home == 5 or home == 25 or home == 24 or home == 13 do
                home = math.random(1, #planets)
            end
        end

        for i, v in pairs(planets) do
            if GAME.galcon.gametype == "Hexagon" then
                if i == 2 or i == 2 + 5 or i == 2 + 10 or i == 2 + 15 or i == 2 + 20 then
                    v.position_x = v.position_x + 35
                end

                if i == 4 or i == 4 + 5 or i == 4 + 10 or i == 4 + 15 or i == 4 + 20 then
                    v.position_x = v.position_x + 35
                end
                if i == 1 or i == 21 or i == 22 or i == 5 or i == 25 or i == 24 then
                    v:destroy()
                end
            end
            if GAME.galcon.gametype == "Donut" then
                if i == (#planets+1)/2 then
                    v:destroy()
                end
            end
            if i == home and amountOfPlay() >= 1 then
                local position_x = v.position_x
                local position_y = v.position_y
                v:destroy()
                g2.new_planet(users[1], position_x, position_y, home_prod, GAME.galcon.global.STARTING_SHIPS);
            end
            if amountOfPlay() >= 2 then
                local home2 = nil
                if home ~= (#planets+1)/2 then
                    home2 = (#planets+1) - home
                end

                if GAME.galcon.gametype == "Hexagon" then
                    --hardcode fix 
                    if     home2 == 9  then home2 = 4   
                    elseif home2 == 24 then home2 = 19
                    elseif home2 == 22 then home2 = 17 
                    elseif home2 == 19 then home2 = 14
                    elseif home2 == 17 then home2 = 12
                    elseif home2 == 14 then home2 = 9
                    elseif home2 == 12 then home2 = 7
                    elseif home2 == 7  then home2 = 2
                    end
                end

                if i == home2 and amountOfPlay() >= 2 then
                    local position_x = v.position_x
                    local position_y = v.position_y
                    v:destroy()
                    g2.new_planet(users[2], position_x, position_y,  home_prod, GAME.galcon.global.STARTING_SHIPS);
                end
                
            end
            
        end
        if mixed then
            GAME.galcon.gametype = "Mix"
        end
    end

    if GAME.galcon.gamemode == "Line" then
        OPTS.sw = sw
        OPTS.sh = sh
        
        sw = sw/1.25
        sh = sh/1.25

        local planets = {}
        local neutrals = 12
        for i=0, neutrals do
            local x,y
            local neutrals_production = 80
            local neutrals_cost = 0
            x = 50 * i 
            y = sh/2

            local planet = g2.new_planet(o, x, y, neutrals_production, neutrals_cost);
            
            table.insert(planets, planet)
        end
        
        local n = math.random(1,2)
        local inverseN = n - 1

        if inverseN == 0 then inverseN = 2 end
        if #users == 1 or #users == 0 then n = 1; inverseN = 2 end
        
        for i,v in pairs(planets) do
            if #users >= 1 then
                if i == 1 then
                    local position_x = v.position_x
                    local position_y = v.position_y
                    v:destroy()
                    g2.new_planet(users[n], position_x, position_y,  home_prod, GAME.galcon.global.STARTING_SHIPS);
                end
            end
            if #users == 2 then
                if i == #planets then
                    local position_x = v.position_x
                    local position_y = v.position_y
                    v:destroy()
                    g2.new_planet(users[inverseN], position_x, position_y,  home_prod, GAME.galcon.global.STARTING_SHIPS);
                end
            end
        end
    end

    if GAME.galcon.gamemode == "Race" then
        OPTS.sw = sw
        OPTS.sh = sh
        
        sw = sw/1.25
        sh = sh/1.25

        local planets = {}
        local planets2 = {}
        local neutrals = 20
        for i=0, neutrals/2 do
            local x,y
            local neutrals_production = 40
            local neutrals_cost = 0
            x = 50 * i 
            y = sh/2
            
            local planet = g2.new_planet(o, x, y, neutrals_production, neutrals_cost);
            local planet2 = g2.new_planet(o, x, y+100, neutrals_production, neutrals_cost);

            table.insert(planets, planet)
            table.insert(planets2, planet2)
        end

        G.targetPlanet = planets[(neutrals+2)/2]
        G.targetPlanet2 = planets2[(neutrals+2)/2]


        local n = math.random(1,2)
        local inverseN = n - 1

        if inverseN == 0 then inverseN = 2 end
        if #users == 1 or #users == 0 then n = 1; inverseN = 2 end

        if #users >= 1 then
            for i,v in pairs(planets) do
                if i == 1 then
                    local position_x = v.position_x
                    local position_y = v.position_y
                    v:destroy()
                    g2.new_planet(users[n], position_x, position_y, 80, 100);
                end
            end
        end
        if #users == 2 then
            for i,v in pairs(planets2) do
                if i == 1 then
                    local position_x = v.position_x
                    local position_y = v.position_y
                    v:destroy()
                    g2.new_planet(users[inverseN], position_x, position_y, 80, 100);
                end
            end
        end
    end

    

    if GAME.galcon.gamemode == "Frenzy" then
        local user_1 = 0
        local user_2 = 0
        OPTS.sw = sw
        OPTS.sh = sh

        sw = sw/1.25
        sh = sh/1.25

        for j, user in pairs(users) do
            if j == 1 then
                user_1 = user
            end
            if j == 2 then
                user_2 = user
            end
        end
            for i=1, OPTS.neutrals/2 do
                local x = math.random(pad,sw-pad)
                local y = math.random(pad,sh-pad)
                local planet_production = math.random(30,100)
                local planet_ships = math.random(15,30)
                    g2.new_planet(user_1, x, y, planet_production, planet_ships);
                if amountOfPlay() == 2 then
                    g2.new_planet(user_2, sw-x, sh-y, planet_production, planet_ships);
                else
                    g2.new_planet(o, sw-x, sh-y, planet_production, planet_ships);
                    o.ships_production_enabled = 1
                end
            end
    end

    if GAME.galcon.gamemode == "Float" then
        GAME.galcon.FLOAT = {
            player_neutrals = 13,
            float_neutrals = 6,
            home_ships = 100,
            home_prod = 100,
            float_shipcount = 25
        }

        local sw = 480
        local sh = 320
        g2.view_set(0, 0, sw, sh);

        GAME.galcon.float.timer = 0
        GAME.galcon.float.wait = 0.2
        GAME.galcon.float.score1 = 0
        GAME.galcon.float.score2 = 0
        GAME.galcon.float.score = GAME.galcon.float.score1 + GAME.galcon.float.score2
        local midmargin = sw/8

        for i=1, GAME.galcon.FLOAT.player_neutrals do
            local x = math.random(0, sw/2 - midmargin)
            local y = math.random()*sh
            local player_neutral_prod = math.random(15,100)
            local player_neutral_cost = math.random(1, 30)

            local player_planet = g2.new_planet(o, x, y, player_neutral_prod, player_neutral_cost);
        end

        for i=1, GAME.galcon.FLOAT.float_neutrals do
            local x = math.random(sw/2 + midmargin*2, sw)
            local y1 = math.random(0, sh/2 - midmargin/1.5)
            local y2 = math.random(sh/2 + midmargin/1.5, sh)
            local range = {y1, y2}
            local y = range[math.random(1, #range)]
            local float_neutral_prod = 0
            local float_neutral_cost = 0

            if i == 1 then
                y = y1
            elseif i == 2 then
                y = y2
            end

            g2.new_planet(o, x, y, float_neutral_prod, float_neutral_cost);
        end

        local home_x = math.random(0, sw/2 - midmargin*4)
        local home_y = math.random()*sh
        if #users >= 1 then 
            local home = g2.new_planet(users[1], home_x, home_y, GAME.galcon.FLOAT.home_prod, GAME.galcon.FLOAT.home_ships)
        end
        g2.planets_settle(0, 0, sw, sh);
        g2.planets_settle();

        g2.new_line(0xff0000, sw/2, 0, sw/2, sh);

        GAME.galcon.float.r = {}
        GAME.galcon.float.v = {}

        local player_planets = g2.search("planet")
        for i, o in pairs(player_planets) do
            if o.ships_production ~= 0 then 
                table.insert(GAME.galcon.float.r, o)
            end
        end

        local player_planets_cost = {}
        for i=1, #GAME.galcon.float.r do
            player_planets_cost[i] = GAME.galcon.float.r[i].ships_value
        end

        local float_planets = g2.search("planet")
        for i, o in pairs(float_planets) do
            if o.ships_production == 0 then
                table.insert(GAME.galcon.float.v, o)
            end
        end

        GAME.galcon.float.reinforceplanet = GAME.galcon.float.r[math.random(1,#GAME.galcon.float.r)]
        GAME.galcon.float.reinforceplanet_cost = GAME.galcon.float.reinforceplanet.ships_value
        local planetradius = prodToRadius(GAME.galcon.float.reinforceplanet.ships_production)
        local radiusbuffer = 5

        local reinforcecircle = g2.new_circle(0x00ff00, GAME.galcon.float.reinforceplanet.position_x, GAME.galcon.float.reinforceplanet.position_y, planetradius + radiusbuffer)

        g2.status = "Time: ".."0".."              ".."Score: ".."0"
        g2.net_send("","status",g2.status)
    end

    if GAME.galcon.gamemode ~= "Grid" and GAME.galcon.gamemode ~= "Float" and GAME.galcon.gamemode ~= "Line" and GAME.galcon.gamemode ~= "Race" and GAME.galcon.gamemode ~= "Classic" and GAME.galcon.gamemode ~= "Stages" then
        g2.planets_settle(0,0,sw,sh);
        g2.planets_settle();
    end
    if seedstring ~= nil then
        net_send('',"message","Map seed: "..seedstring)
    else
        net_send('',"message","Map seed: "..(seed % 1616606700) )
    end
    GAME.galcon.global.matchXp = 0 
    g2.net_send("","sound","sfx-start")
    local r = g2.search("planet")
end

function playersWithStatus(status)
    local players = {}

    for i,v in pairs(GAME.clients) do
        if (v.status == status) then
            table.insert(players, i)
        end
    end

    return players
end

function requeueLoser(uid)
    for i, v in pairs(GAME.clients) do
        if #playersWithStatus("queue") > 0 then
            --print("v.uid: ".. v.uid .. " uid: ".. uid)
            if (v.uid == uid) then
                v.status = "away"
                clients_queue()
                v.status = "queue"
                clients_queue()
                net_send("","message",v.name .. " is /queue")
            end
        end
    end
end

function getBreadMessage()
    local messageList = {[0]="BAKED", [1]="TOASTED", 
        [2]="ROLLED", [3]="COOKED", [4]="FLOURED", 
        [5]="CRUNCHED", [6]="SLICED", [7]="DIPPED",
        [8]="BOWLED", [9]="SANDWICHED", [10]="SERVED",
        [11]="FLUFFED", [12]="LEAVENED", [13]="ATE",
        [14]="KNEADED",[15]="TOSSED", [16]="LOAFED",
        [17]="BUTTERED", [18]="HEELED", [19]="FERMENTED",
        [20]="YEASTED", [21]="CRUSTED"}
    local ranPick = math.floor(math.random()*#messageList)
    return messageList[ranPick]
end

function galcon_stop(res, timerWinner, time)
    if res == true then
        local winner = timerWinner or most_production()
        local loser
        printEndProdAndShip()
        if winner ~= nil and winner ~= "galaxy227" then
            loser = find_enemy(winner.user_uid)
            if GAME.galcon.gamemode ~= "Race" then
                if GAME.galcon.global.stupidSettings.breadmode and (GAME.clients[winner.user_uid].name == "bread" or GAME.clients[loser.user_uid].name == "bread") then 
                    local message = getBreadMessage()
                    net_send("", "message", winner.title_value.." "..message.. " "..loser.title_value)
                    if(GAME.clients[loser.user_uid] ~= nil) then
                        GAME.clients[loser.user_uid].title = message 
                    end
                elseif GAME.galcon.global.stupidSettings.saandmode then
                    if string.lower(GAME.clients[winner.user_uid].name) == "binah." then
                        net_send("","message",winner.title_value.." enslaved "..loser.title_value)
                        net_send("", "message", "BOW THEE SUBJECT "..loser.title_value.."!")
                        if(GAME.clients[loser.user_uid] ~= nil) then
                            GAME.clients[loser.user_uid].title = "Saand Minion"
                        end
                    else
                        if GAME.clients[winner.user_uid] ~= nil then
                            if (GAME.clients[winner.user_uid].title) == "Saand Minion" then
                                GAME.clients[winner.user_uid].title = "Freed Minion"
                                net_send("", "message", winner.title_value.." escaped the dominion!")
                            else
                                net_send("", "message", winner.title_value.." dodged enslavement!")
                            end
                        end 
                    end
                else
                    local messageOptions = {winner.title_value.." conquered the galaxy"}
                    net_send("","message",messageOptions[math.random(1, #messageOptions)])
                end
            else
                net_send("","message",winner.title_value.." finished in "..GAME.galcon.finishTime.." seconds")
            end

            for j, u in pairs(GAME.galcon.scorecard) do
                local uid = winner.user_uid --stupid negatives in lua being treated as strings
                if(tonumber(uid) < 0) then
                    uid = tonumber(uid)
                end
                if uid == j then
                    if GAME.galcon.global.stupidSettings.silverMode and (GAME.clients[uid].name == "silvershad0w") then
                        u = u + 15
                    else
                        u = u + 1
                    end
                    GAME.galcon.scorecard[j] = u
                    handlePlayerMatchUpdate(botUidFix({uid=uid}), true, GAME.galcon.gamemode)
                    handlePlayerXpUpdate(botUidFix({uid=uid}), true)
                    if GAME.galcon.global.CONFIGS.saandCoins.enableSaandCoins and tonumber(uid) > 0 then
                        net_send(j,"message","You earned 1 SaandCoin!")
                        GAME.clients[j].coins = GAME.clients[j].coins + 1
                        playerData.updateCoins(winner.user_uid, 1)
                        playerData.saveData()
                        editPlayerData("coin-u", winner.user_uid, 1)
                    end                
                end
            end
            
            if loser ~= nil and loser.user_uid ~= nil then
                local winner_uid = botUidFix({uid=winner.user_uid}) --dumb hack to make botUidFix work since its expecting a table with .uid property
                local loser_uid = botUidFix({uid=loser.user_uid})

                handlePlayerMatchUpdate(loser_uid, false, GAME.galcon.gamemode)
                handlePlayerXpUpdate(loser_uid, false)
                
                playerWinData.loadData(true)
                playerWinData.updateMatches(winner_uid, loser_uid, true)
                playerWinData.updateMatches(loser_uid, winner_uid, false)
                playerWinData.saveData()
                local samebot = false
                if(tonumber(winner.user_uid) < 0 and tonumber(loser.user_uid) < 0) then
                    if(GAME.clients[tonumber(winner.user_uid)].botName == GAME.clients[tonumber(loser.user_uid)].botName) then
                        samebot = true
                    end
                end
                if not samebot then
                    elo.load_ratings()
                    elo.update_elo(string.lower(winner_uid), string.lower(loser_uid), true)
                    elo.save_ratings()
                else
                    print("same bot!")
                end
            end
           
            --print("loser uid: ".. loser.user_uid)
            if GAME.galcon.global.WINNER_STAYS == true and loser ~= nil then
                requeueLoser(loser.user_uid)
            end
        else
            if winner == "galaxy227" then
                net_send("", "message", "galaxy227 wins by timers default!")
            end
        end
        if(winner ~= nil and tonumber(winner.user_uid) < -10) then
            getBotGG(tonumber(winner.user_uid), true)
        end
        if(loser ~= nil and tonumber(loser.user_uid) < -10) then
            getBotGG(tonumber(loser.user_uid), false)
        end
    end
    g2.net_send("","sound","sfx-stop");
    --[[ if GAME.galcon.setmode == false then
        GAME.engine:next(GAME.modules.lobby)
    else
        g2.state = "menu" ]]
        g2.state = "play"
        GAME.engine:next(GAME.modules.lobby)
    --[[ end ]]
    for i,v in pairs(GAME.clients) do
        v.inGame = false
    end
end

function getNumNonNeutralUsers()
    local total = 0
    for k,v in pairs(GAME.galcon.users) do 
        if (v.title_value ~= "neutral") then
            total = total + 1
        end
    end
    return total
end

function galcon_classic_loop()
    local r = count_production()
    local total = 0
    for k,v in pairs(r) do 
        total = total + 1 
    end
    for _,v in pairs(GAME.galcon.global.BOTS)do
		if v.run then
			v.run:loop()
		end
	end
    GAME.galcon.global.matchXp = GAME.galcon.global.matchXp + 1
    check_for_match_end()
    --net_send("","view",json.encode({math.random(-1000, 10),math.random(-1000, 10), math.random(10, 1000), math.random(10, 1000)}))
end

function check_for_match_end()
    local G = GAME.galcon

    local shipCounts = count_ships()
    local numPlayersWithShips = 0
    for k, v in pairs(shipCounts) do
        numPlayersWithShips = numPlayersWithShips + 1
    end

    local prodCounts = count_production()
    local numPlayersWithPlanets = 0
    for k, v in pairs(prodCounts) do
        numPlayersWithPlanets = numPlayersWithPlanets + 1
    end

    -- there was a single player and they have no ships anymore.
    if #G.users <= 1 and numPlayersWithShips == 0 then
        --print("Single user no ships")
        galcon_stop(false)
    end
    -- there were multiple players and one person completely died
    if #G.users > 1 and numPlayersWithShips <= 1 then
        if GAME.modules.galcon.timeout > 3 then
            --print("Multi-user one died")
            galcon_stop(true)
        end
    end
    -- one person is floating around like a jackass OR a single person started a game alone.
    if numPlayersWithPlanets <= 1 and GAME.galcon.global.SOLO_MODE == false then
        if GAME.modules.galcon.timeout > 10 then
            --print("Single user")
            galcon_stop(#G.users > 1)
        end
    else
        GAME.modules.galcon.timeout = 0
    end
end

function calc_Timer_Win() 
    local prodWinner = most_production_tie_check()
    local shipWinner = most_ships_tie_check()
    local winner = "galaxy227"
    if shipWinner == "tie" then
        if prodWinner ~= "tie" then
            winner = prodWinner
        end
    else
        winner = shipWinner
    end
    
    return winner

end

function printEndProdAndShip()
    local ships = count_ships()
    local prod = count_production()
    for o,v in pairs(prod) do
        local ship = math.floor(ships[o])
        local rem = math.floor(math.fmod(ships[o], 1) * 1000)
        ship = ship + (rem/1000)
        local fixedUID = o.user_uid
        if(tonumber(o.user_uid) < 0) then fixedUID = tonumber(o.user_uid) end
        net_send("","chat", json.encode({color=GAME.clients[fixedUID].color,value= o.title_value .. "- Production: "..v .. "   Ships: "..ship}))

    end

end

function galcon_surrender(uid)
    local G = GAME.galcon

    local user = find_user(uid)
    if user == nil then return end
    for n,e in pairs(g2.search("planet owner:"..user)) do
        e:planet_chown(G.neutral)
    end
end

function editPlayerData(mode, uid, data)
    --name, color, coin-u, coin-s, title, ship, skin, ownedships, ownedskins
    playerData_init(true)
    -- print("Mode: " .. mode)
    -- print("uid:" .. uid)
    -- print("data: ".. data)
    if mode == "name" then
        playerData.setPlayerDisplayName(uid, data)
    elseif mode == "color" then
        playerData.setPlayerColor(uid, data)
    elseif mode == "coin-u" then
        playerData.updateCoins(uid, data)
    elseif mode == "coin-s" then
        playerData.setPlayerCoins(uid, data)
    elseif mode == "title" then
        playerData.setPlayerTitle(uid, data)
    elseif mode == "quote" then
        playerData.setPlayerQuote(uid, data)
    elseif mode == "ship" then
        playerData.setPlayerShip(uid, data)
    elseif mode == "xp" then
        playerData.setPlayerXP(uid, data)
    elseif mode == "level" then
        playerData.setPlayerLevel(uid, data)
    elseif mode == "prestige" then
        playerData.setPlayerPrestige(uid, data)
    elseif mode == "skin" then
        playerData.setPlayerSkin(uid, data)
    elseif mode == "ownedships" then
        playerData.updateShipList(uid, data)
    elseif mode == "ownedskins" then
        playerData.updateSkinList(uid, data)
    elseif mode == "stats" then
        playerData.setPlayerStats(uid, data)
    end
    playerData.saveData()
end

function galcon_init()
    GAME.modules.galcon = GAME.modules.galcon or {}
    GAME.galcon = GAME.galcon or {}
    local obj = GAME.modules.galcon

    function obj:get_player_stats()
        local stats = {}
        for i,v in pairs(GAME.galcon.users) do
            local name = v.title_value
            local prod = count_productionPlayer(v.user_uid)
            local ships = count_shipsPlayer(v.user_uid)
            stats[name] = {prod = prod, ships = ships}
        end
        return stats
    end

    function obj:get_spectator_status(stats)
        local status = ""
        local count = 1
        local maxplayers = 2
        local timer = " [" .. get_formmatted_time(self.timeLeft) .. "] "
        local versus = " VS "
        for i,v in pairs(stats) do
            if count > maxplayers then
                break
            end
            status = status .. i .. " - P: " .. v.prod .. " S: " .. string.format('%d', v.ships)
            if count == 1 and #playersWithStatus("play") > 1 then
                if GAME.galcon.global.TIMER_LENGTH ~= 0 then
                    status = status .. timer
                else
                    status = status .. versus
                end
            end
            count = count + 1
        end
        if #playersWithStatus("play") == 1 and GAME.galcon.global.TIMER_LENGTH ~= 0 then
            status = timer .. " " .. status
        end
        return status
    end

    function obj:is_spectator(client)
        if client.ui_ships_show_mask == 0xF then
            return true
        end
    end

    function obj:update_status(uid, status)
        if uid == g2.uid then
            g2.status = status
        else
            g2.net_send(uid, "status", status)
        end
    end

    function obj:update_player_status()
        for i,v in pairs(GAME.clients) do
            if GAME.galcon.global.TIMER_LENGTH ~= 0 and v.inGame then
                obj:update_status(v.uid, get_formmatted_time(self.timeLeft))
            end
        end
    end

    function obj:update_spectator_status()
        for i,v in pairs(GAME.clients) do
            if not v.inGame then
                obj:update_status(v.uid, obj:get_spectator_status(self.playerStats))
            end
        end
    end

    function obj:init()
        g2.state = "play"
        params_set("state","play")
        params_set("html",ingamePauseMenu())
        galcon_classic_init()
        self.time = 0
        self.wait = 1
        self.counter = 0
        self.timeout = 0
        self.floatSpawn = false
        GAME.galcon.finishTime = 0
        self.raceLock = false
        self.hexaGridLock = false
        self.playerStats = obj:get_player_stats()
        self.statusTimer = ""
        self.spectatorStatus = ""
        self.timeLeft = 0
    end
        
    function obj:loop(t)
        galcon_classic_loop()
        self.time = self.time + t
        self.timeout = self.timeout + t

        self.playerStats = obj:get_player_stats()
        --self.spectatorStatus = obj:set_spectator_status(self.playerStats)
        
        obj:update_player_status()
        obj:update_spectator_status()
        
        if GAME.galcon.gamemode == "Float" then
            update_score(self.time)
            displayFloatTimer(self.time)
            if self.floatSpawn == false then
                if #GAME.galcon.users >= 1 then 
                    GAME.galcon.float.float_fleet = g2.new_fleet(GAME.galcon.users[1], 25, GAME.galcon.float.v[math.random(1, #GAME.galcon.float.v)],GAME.galcon.float.r[math.random(1, #GAME.galcon.float.r)])
                end
                self.floatSpawn = true
            end
        end
        if GAME.galcon.global.TIMER_LENGTH ~= 0 then
            self.timeLeft = GAME.galcon.global.TIMER_LENGTH - math.floor(self.time)
            --displayTimer(self.timeLeft)
            if self.timeLeft < 1 then
                galcon_stop(#GAME.galcon.users>1, calc_Timer_Win())
            end
        end
        if GAME.galcon.gamemode == "Race" then
            if self.time >= GAME.galcon.finishTime + 1 and GAME.galcon.finishTime ~= 0 then
                galcon_stop(true)
            end
        end
        if GAME.galcon.gamemode == "Grid" and GAME.galcon.gametype == "Hexagon" and amountOfPlay() == 1 then
            local count = 0
            for _i,_v in pairs(g2.search("planet -neutral")) do
                count = count + 1
            end
            if count == 19 and self.hexaGridLock == false then
                net_send('', "message", self.time)
                self.hexaGridLock = true
                galcon_stop(true)
            end
        end
       
    end
    function obj:event(e)
        if e.type == 'net:message' and string.lower(e.value) == '/abort' then
            if isAdmin(e.name) then
                galcon_stop(false)
            end
        end
        if e.type == 'net:leave' then
            --print("called from galcon_init")
            galcon_surrender(e.uid)
            clients_leave(e, false)
        end
        if (e.type == 'net:message' or e.type == 'onclick') and string.lower(e.value) == '/surrender' then
            if e.uid then
                net_send("","message",GAME.clients[e.uid].displayName.." /surrender")
                galcon_surrender(e.uid)
            else 
                net_send("","message",GAME.clients[g2.uid].displayName.." /surrender")
                galcon_surrender(g2.uid)
            end
        end
        if e.type == 'onclick' and string.lower(e.value) == '/ragequit' then
            print("called from rage quit click")
            if e.uid then
                galcon_surrender(e.uid)
            else 
                galcon_surrender(g2.uid)
            end
            GAME.clients[e.uid] = nil
            clients_leave(e, true)
        end

        if GAME.galcon.gamemode == "Stages" then
            if math.floor(self.time) == 30 then
                stage2(e.uid)
            end
            if math.floor(self.time) == 70 then
                stage3(e.uid)
            end
            if math.floor(self.time) == 150 and self.counter < 110  then
                local time = 150
                stage4()

                if math.floor(self.time) == time then
                        self.time = self.time - self.wait
                        self.counter = self.counter + 1
                end
            end
            if self.counter == 60 then
                stage5()
            end
            if math.floor(self.time) >= 200 then
                local time = 200
                stage6()
                g2.status = "Final stage"
                g2.net_send("","status",g2.status)

                if math.floor(self.time) == time then
                    self.time = self.time - self.wait
                end
            end
        end

        if GAME.galcon.gamemode == "Float" then
            local sw = 480
            local sh = 320

            if GAME.galcon.float.float_fleet ~= nil then
                if GAME.galcon.float.float_fleet.fleet_ships < GAME.galcon.FLOAT.float_shipcount then
                    galcon_stop(true)
                    print_scoreTime(self.time)
                end
                local approx_float_fleet_r = sw/16
                if GAME.galcon.float.float_fleet.position_x < sw/2 + approx_float_fleet_r then
                    galcon_stop(true)
                    print_scoreTime(self.time)
                end
            end
        end
        if GAME.galcon.gamemode == "Race" then
            if GAME.galcon.targetPlanet.ships_value > 0 or GAME.galcon.targetPlanet2.ships_value > 0 then
                if self.raceLock == false then 
                    local winner = 0
                    GAME.galcon.finishTime = self.time
                    self.raceLock = true
                end
            end
        end
    end
end
function count_productionPlayer(uid)
    local prod = 0
    local user = find_user(uid)
    local userPlanets = g2.search("planet owner:" .. user)
    for _i, planet in ipairs(userPlanets) do
        prod = prod + planet.ships_production
    end
    return prod
end

function count_shipsPlayer(uid)
    local ships = 0
    local user = find_user(uid)
    local userPlanets = g2.search("planet owner:" .. user)
    for _i, planet in ipairs(userPlanets) do
        ships = ships + planet.ships_value
    end

    local userFleets = g2.search("fleet owner:" .. user)
    for _i, o in ipairs(userFleets) do
        ships = ships + o.fleet_ships
    end
    return ships
end
function clients_leave(e, rageQuit)
    if rageQuit then
        net_send("","message",GAME.clients[e.uid].displayName .. " rage quit!")
    end
    if e.uid ~= g2.uid then
        net_send(e.uid,"state","quit")
    end
    if GAME.clients[e.uid] ~= nil then
        if GAME.clients[e.uid].status == "play" and playersWithStatus("play") == 1 and g2.state ~= "lobby" then
            GAME.engine:next(GAME.modules.lobby)
        end
        GAME.clients[e.uid].status = "away"
        clients_queue()
        GAME.clients[e.uid] = nil
        play_sound("sfx-leave")
        clients_queue()
    end
end
--------------------------------------------------------------------------------
function register_init()
    GAME.modules.register = GAME.modules.register or {}
    local obj = GAME.modules.register
    obj.t = 0
    local playersPlay = 0
    local playersLimit
    function obj:loop(t)
        if GAME.module == GAME.modules.menu then return end
        self.t = self.t - t
        if self.t < 0 then
            self.t = 10
            -- update players indicator
            if GAME.galcon.global ~= nil then
                playersLimit = GAME.galcon.global.MAX_PLAYERS
            end
            if GAME.galcon.tournament then
                playersLimit = 3
            end
            playersPlay = #playersWithStatus("play") + #playersWithStatus("queue")
            -- update server list title
            g2_api_call("register",json.encode({title=GAME.data.title .. " - "..playersPlay..'/'..playersLimit,port=GAME.data.port}))
        end
    end
end
--------------------------------------------------------------------------------
function engine_init()
    GAME.engine = GAME.engine or {}
    GAME.modules = GAME.modules or {}
    local obj = GAME.engine

    function obj:next(module)
        GAME.module = module
        GAME.module:init()
    end
    
    function obj:init()
        if g2.headless then
            GAME.data = { port = g2.port }
            g2.net_host(GAME.data.port)
            GAME.engine:next(GAME.modules.lobby)
        else
            self:next(GAME.modules.menu)
        end
    end
    
    function obj:event(e)
--         print("engine:"..e.type)
        GAME.modules.clients:event(e)
        GAME.modules.params:event(e)
        GAME.modules.chat:event(e)
        GAME.module:event(e)
        if e.type == 'onclick' then 
            GAME.modules.client:event(e)
        end
    end
    
    function obj:loop(t)
        GAME.module:loop(t)
        GAME.modules.register:loop(t)
    end
end
--------------------------------------------------------------------------------
function elo_init()
    elo.load_ratings()
    elo.set_k(15)
end
function playerData_init(initial)
    playerData.loadData(initial)
end
function playerWinData_init(initial)
    playerWinData.loadData(initial)
end
function mod_init()
    global("GAME")
    GAME = GAME or {}
    admins_init()
    engine_init()
    menu_init()
    clients_init()
    params_init()
    chat_init()
    lobby_init()
    galcon_init()
    register_init()
    elo_init()
    playerData_init(true)
    playerWinData_init(true)
    if g2.headless == nil then
        client_init()
    end
end
--------------------------------------------------------------------------------
function init() GAME.engine:init() end
function loop(t) GAME.engine:loop(t) end
function event(e) GAME.engine:event(e) end
--------------------------------------------------------------------------------
function net_send(uid,mtype,mvalue) -- HACK - to make headed clients work
    if g2.headless == nil and (uid == "" or uid == g2.uid) then
        GAME.modules.client:event({type="net:"..mtype,value=mvalue})
    end
    g2.net_send(uid,mtype,mvalue)
end
function play_sound(name)
    net_send("", "sound", name)
end
--------------------------------------------------------------------------------
mod_init()