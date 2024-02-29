require("mod_common_utils")
require("mod_elo")
require("utils")
require("html")
require("stages")
require("mapkit")  

LICENSE = [[
mod_server.lua

Copyright (c) 2013 Phil Hassey
Modifed by: Tycho2

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
    function obj:init()
        g2.html = startupMenu()
        GAME.data = json.decode(g2.data)
        if type(GAME.data) ~= "table" then GAME.data = {} end
        g2.form.port = GAME.data.port or "23099"
        g2.state = "menu"
        GAME.galcon.wins = 0
        GAME.galcon.scorecard = {}
        GAME.galcon.gamemode = "Classic" or "Stages" or "Frenzy" or "Grid" or "Float" or "Line" or "Race"
        GAME.galcon.tournament = false
        GAME.galcon.setmode = false
        GAME.galcon.global = {
            TITLE = "Beta V3 SaandCon", --Display title on main g2 lobby screen
            MAX_PLAYERS = 2,
            SOLO_MODE = false, --for if someone wants to play a solo game like grid or something
            MAP_STYLE = 3,
            SEED_DATA = {
                SEED = 1,
                PREV_SEED = 1,
                CUSTOMISED = false,
                KEEP_SEED = false,
            },
            stupidSettings = {
                silverMode = false,
                yodaFilter = false,
            },
        }
    end
    function obj:loop(t)
    end
    function obj:event(e)
        if e.type == 'onclick' and e.value == 'host' then
            GAME.data.port = g2.form.port
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
function clients_queue()
    _clients_queue()
    resetLobbyHtml()
end
function _clients_queue()
    local colors = {
        0x0000ff,0xff0000,
        0xffff00,0x00ffff,
        0xffffff,0xff8800,
        0x99ff99,0xff9999,
        0xbb00ff,0xff88ff,
        0x9999ff,0x00ff00,
    }
    -- delete colors above MAX_PLAYERS treshold
    for i, v in pairs(colors) do
        if (i > GAME.galcon.global.MAX_PLAYERS) then
            colors[i] = nil
        end
    end

    local q = nil
    for k,e in pairs(GAME.clients) do
        -- set color of "away" and "queue" players to grey
        if e.status == "away" or e.status == "queue" then
            e.color = 0x555555
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
            q.color = v
            q.status = "play"
            net_send("","message",q.name .. " is /play")
            return
        end
    end
end

function initAdmins()
    GAME.admins = GAME.admins or {}
    GAME.admins[cleansePlayerName(g2.name)] = true
end

function makeAdmin(name)
    name = cleansePlayerName(name)
    initAdmins()
    GAME.admins[name] = true
    return true
end

function unadmin(name)
    name = cleansePlayerName(name)
    initAdmins()
    if name ~= cleansePlayerName(g2.name) and GAME.admins[name] ~= nil then 
        GAME.admins[name] = nil
        return true
    end
    return false
end

function isAdmin(name) 
    name = cleansePlayerName(name)
    initAdmins()
    return GAME.admins[name] ~= nil
end

function cleansePlayerName(name)
    name = string.lower(name)
    if name == "gamaray1719" then
        return "Zen_Power17"
    elseif name == "saand.-" or name == "saand" then
        return "Saand"
    end
    return name
end 

function clients_init()
    GAME.modules.clients = GAME.modules.clients or {}
    GAME.clients = GAME.clients or {}
    local obj = GAME.modules.clients
    function obj:event(e)
        if e.type == 'net:join' then
            if amountOfPlay() < GAME.galcon.global.MAX_PLAYERS then
                GAME.clients[e.uid] = {uid=e.uid,name=e.name,status="queue"}
            else
                GAME.clients[e.uid] = {uid=e.uid,name=e.name,status="away"}
            end
            clients_queue()
            net_send("","message",e.name .. " joined")
            g2.net_send("","sound","sfx-join");

            if GAME.galcon.scorecard[e.uid] == nil then
                GAME.galcon.scorecard[e.uid] = GAME.galcon.wins
            end
        end
        if e.type == 'net:leave' then
            --print("called from first net:leave")
            GAME.clients[e.uid] = nil
            net_send("","message",e.name .. " left")
            g2.net_send("","sound","sfx-leave");
            clients_queue()
        end
        if (e.type == 'net:message' and string.lower(e.value) == '/play') or (e.type == "net:message" and string.lower(e.value) == "/queue") then
            if GAME.clients[e.uid].status == "away" then
                GAME.clients[e.uid].status = "queue"
                clients_queue()
                net_send("","message",e.name .. " is /queue")
            end
        end
        if (e.type == 'net:message' and string.lower(e.value) == '/lobby') then
            --net_send("", "message", "<debug> net:message for lobby")
            resetLobbyHtml(e)
        end
        if (e.type == 'net:message' and string.lower(e.value) == '/mode') then
            --net_send("", "message", "<debug> net:message for mode")
            modeTab(e)
        end
        if (e.type == 'net:message' and string.lower(e.value) == '/leaderboard') then
            --net_send("", "message", "<debug> net:message for leaderboard")
            loadScoreboard(e)
        end
        if (e.type == 'net:message' and string.lower(e.value) == '/settings') then
            --net_send("", "message", "<debug> net:message for settings")
            settingsTab(e)
        end
        if e.type == 'net:message' and string.lower(e.value) == '/away' then
            if GAME.clients[e.uid].status == "play" or GAME.clients[e.uid].status == "queue" then
                GAME.clients[e.uid].status = "away"
                clients_queue()
                net_send("","message",e.name .. " is /away")
            end
        end
        -- can break a lot of things DONT USE
        if e.type == "net:message" and string.sub(e.value,1,11) == "/maxplayers" then
            local maxPlayers = tonumber(string.sub(e.value,13))
            GAME.galcon.global.MAX_PLAYERS = maxPlayers
            clients_queue()
            net_send('', "message", "Max players set to "..GAME.galcon.global.MAX_PLAYERS)
        end
        if e.type == 'net:message' and string.lower(e.value) == '/who' then
            local msg = ""
            for _,c in pairs(GAME.clients) do
                msg = msg .. c.name .. ", "
            end
            net_send(e.uid,"message","/who: "..msg)
        end
        if e.type == 'net:message' and string.lower(e.value) == '/color' or e.type == 'net:message' and string.lower(e.value) ==  '/colors' then
            net_send(e.uid,"message",'(Server -> '..e.name..') Type "/hex [0x######] to change your color."')
        end
        if e.type == 'net:message' and string.lower(string.sub(e.value,1,4)) == "/hex" and string.lower(string.sub(e.value,1,8)) ~= "/hexagon" then
            if GAME.clients[e.uid].status == "play" then
                
                local color = 0
                color = string.sub(e.value,6)
                color = string.lower(color)
                if string.sub(e.value,6,7) ~= "0x" then
                    color = "0000000"
                end
                if limitColor(color) == "0000000" then
                    net_send(e.uid,'message','(Server -> '..e.name..') Error, format should be: 0x######, # = 1-9 or A-F')
                end
                if string.len(color) == 8 then
                    if limitColor(color) ~= "000000" then
                        color = limitColor(color)
                    else    
                        color = "000000"
                    end
                else
                    net_send(e.uid,'message','(Server -> '..e.name..') Error, format should be: 0x######')
                end
                --print(color)
                if string.len(color) == 8 and color ~= "000000" then
                    GAME.clients[e.uid].color = color
                    net_send(e.uid,'message','(Server -> '..e.name..') HEX-color changed to: '..color)
                    resetLobbyHtml()
                elseif color == "000000" then
                    net_send(e.uid,'message','(Server -> '..e.name..') Error, color too dark.')
                end
                --print(dump(GAME.clients[e.uid]))
            end
        end
        if e.type == 'net:message' and string.lower(e.value) == "/awayall" then
            if isAdmin(e.name) then
                for _,c in pairs(GAME.clients) do
                    if c.uid ~= e.uid then
                        c.status = "away"
                        net_send("","message",c.name .. " is /away")
                    end
                end
                clients_queue()
            end
        end
        if e.type == 'net:message' and string.lower(string.sub(e.value,1,6)) == "/admin" then
            if isAdmin(e.name) then
                local adminName = string.sub(e.value,8)
                local worked = makeAdmin(adminName)
                if worked then 
                    net_send("","message",e.name .. " /admin " .. adminName)
                    resetLobbyHtml()
                else
                    net_send(e.uid,'message','(Server -> '..e.name..') Error, failed to admin '.. adminName .. '.')
                end
            end
        end
        if e.type == 'net:message' and string.lower(string.sub(e.value,1,8)) == "/unadmin" then
            if isAdmin(e.name) then
                local adminName = string.sub(e.value,10)
                local worked = unadmin(adminName) 
                if worked then 
                    net_send("","message",e.name .. " /unadmin " .. adminName)
                    resetLobbyHtml()
                else
                    net_send(e.uid,'message','(Server -> '..e.name..') Error, failed to unadmin '.. adminName .. '.')
                end
            end
        end
        if e.type == 'net:message' and string.lower(e.value) == "/reset" then
            if isAdmin(e.name) then
                for i, e in pairs(GAME.galcon.scorecard) do
                    GAME.galcon.scorecard[i] = 0
                end
                net_send("","message",e.name .. " /reset")
                clients_queue()
            end
        end
        if e.type == 'net:message' and string.lower(e.value) == "/silver" then
            if e.name == "silvershad0w" or e.name == "HostAphid" then
                net_send("", "message", "Bro is he!")
                if GAME.galcon.global.stupidSettings.silverMode then
                    GAME.galcon.global.stupidSettings.silverMode = false
                    net_send("", "message", "SILVER MODE DEACTIVATED")
                else
                    GAME.galcon.global.stupidSettings.silverMode = true
                    net_send("", "message", "SILVER MODE ACTIVATED")
                end
            else
                net_send("", "message", "You are not he!")
            end
            
        end
        if e.type == 'net:message' and string.lower(e.value) == "/ggwp" then
            net_send("", "message", e.name .. " /ggwp")
            if e.name == "hurrinado334" or e.name == "HostAphid" then
                net_send("", "message", "You are fragile enough...")
                if GAME.galcon.global.stupidSettings.yodaFilter then
                    GAME.galcon.global.stupidSettings.yodaFilter = false
                    net_send("", "message", "Yoda filter deactivated!")
                else
                    GAME.galcon.global.stupidSettings.yodaFilter = true
                    net_send("", "message", "Yoda filter active!")
                end
            else
                if string.lower(e.name) == "master_yoda_" then
                    if GAME.galcon.global.stupidSettings.yodaFilter then
                        net_send("", "message", "Nope you did this to yourself ".. e.name)
                    else
                        net_send("", "message", "If you insist on it being on...")
                        GAME.galcon.global.stupidSettings.yodaFilter = true
                        net_send("", "message", "Yoda filter active!")
                    end
                end
                net_send("", "message", "You are not fragile enough to be spared yodas berating.")
            end
        end
        if e.type == 'net:message' and string.lower(e.value) == "/mins" then
            net_send("", "message", e.name .. " /mins")
            net_send("", "message", "MINS MINS MINS MINS MINS MINS MINS MINS MINS MINS")
        end
        if e.type == 'net:message' and string.lower(string.sub(e.value, 1, 4)) == "/put" then
            if isAdmin(e.name) then
                local userToPutAway = ""
                if string.lower(string.sub(e.value, 6, 9)) == "away" then
                    userToPutAway = string.lower(string.sub(e.value, 11))
                end
                for i,v in pairs(GAME.clients) do
                    if string.lower(v.name) == userToPutAway then
                        v.status = "away"
                    end
                end
            end
            clients_queue()
        end
        if e.type == 'net:message' and string.lower(e.value) == '/ragequit' then
            --print("called from rage quit message")
            if e.uid then
                galcon_surrender(e.uid)
            else 
                galcon_surrender(g2.uid)
            end
            GAME.clients[e.uid] = nil
            clients_leave(e, true)
        end
        if e.type == 'net:message' and string.lower(e.value) == '/wardrobe' then
            net_send("", "message", "Wardrobe coming soon!")
        end
        if e.type == 'net:message' and string.lower(e.value) == "/classic" then
            if g2.state == "lobby" then
                GAME.galcon.gamemode = "Classic"
                GAME.galcon.global.SOLO_MODE = false
                net_send("","message",e.name .. " /classic")
                net_send("","message","Game mode changed to: Classic.")
                clients_queue()
            end
        end
        if e.type == 'net:message' and string.find(string.lower(e.value), "/seed") ~= nil then
            net_send("", "message", e.name .." " .. e.value)
            local extract = string.sub(e.value, 7, string.len(e.value))
            local seed = math.random(os.time())
            local customised = false
            if string.len(extract) > 0 then
                if tonumber(extract) ~= nil then
                    local converted = tonumber(extract)
                    if type(converted) == "number" and (math.floor(converted) == converted) then
                        seed = converted
                    else
                        seed = toNumberExtended(extract)
                    end
                else
                    seed = toNumberExtended(extract)
                end
                customised = true
            end
            GAME.galcon.global.SEED_DATA.SEED = seed
            GAME.galcon.global.SEED_DATA.CUSTOMISED = customised
            if customised then
                resetLobbyHtml()
            else
                net_send("", "message", "Seed format not recognised, keeping random seed")
                resetLobbyHtml()
            end
        end
        if e.type == 'net:message' and string.lower(e.value) == "/replayseed" then
            net_send("", "message", e.name .. "/replayseed")
            GAME.galcon.global.SEED_DATA.SEED = GAME.galcon.global.SEED_DATA.PREV_SEED
            GAME.galcon.global.SEED_DATA.CUSTOMISED = true
            resetLobbyHtml()
        end
        if e.type == 'net:message' and string.lower(e.value) == "/keepseed" then
            net_send("", "message", e.name .. "/keepseed")
            if GAME.galcon.global.SEED_DATA.KEEP_SEED then
                net_send("", "message", "keepseed off!")
                GAME.galcon.global.SEED_DATA.KEEP_SEED = false
            else
                net_send("", "message", "keepseed on!")
                GAME.galcon.global.SEED_DATA.KEEP_SEED = true
                GAME.galcon.global.SEED_DATA.CUSTOMISED = true
                GAME.galcon.global.SEED_DATA.SEED = GAME.galcon.global.SEED_DATA.PREV_SEED
            end
        end
        if e.type == 'net:message' and string.lower(e.value) == "/stages" then
            if g2.state == "lobby" then
                GAME.galcon.gamemode = "Stages"
                GAME.galcon.global.SOLO_MODE = false
                net_send("","message",e.name .. " /stages")
                net_send("","message","Game mode changed to: Stages.")
                clients_queue()
            end
        end
        if e.type == 'net:message' and string.lower(e.value) == "/frenzy" then
            if g2.state == "lobby" then
                GAME.galcon.gamemode = "Frenzy"
                GAME.galcon.global.SOLO_MODE = false
                net_send("","message",e.name .. " /frenzy")
                net_send("","message","Game mode changed to: Frenzy.")
                clients_queue()
            end
        end
        if e.type == 'net:message' and string.lower(e.value) == "/grid" then
            if g2.state == "lobby" then
                GAME.galcon.gamemode = "Grid"
                GAME.galcon.global.SOLO_MODE = false
                GAME.galcon.gametype = "Standard" or "Donut" or "Hexagon"
                net_send("","message",e.name .. " /grid")
                net_send("","message","Game mode changed to: Grid.")
                clients_queue()
            end
        end
        if e.type == 'net:message' and string.lower(e.value) == "/standard" then
            if g2.state == "lobby" then
                GAME.galcon.gametype = "Standard"
                net_send("","message",e.name .. " /standard")
                clients_queue()
            end
        end
        if e.type == 'net:message' and string.lower(e.value) == "/donut" then
            if g2.state == "lobby" then
                GAME.galcon.gametype = "Donut"
                net_send("","message",e.name .. " /donut")
                clients_queue()
            end
        end
        if e.type == 'net:message' and string.lower(e.value) == "/hexagon" then
            if g2.state == "lobby" then
                GAME.galcon.gametype = "Hexagon"
                net_send("","message",e.name .. " /hexagon")
                clients_queue()
            end
        end

        if e.type == 'net:message' and string.lower(e.value) == "/float" then
            if g2.state == "lobby" then
                GAME.galcon.gamemode = "Float"
                GAME.galcon.global.SOLO_MODE = true --DONT FORGET TO CHANGE THIS LATER IF FLOAT BECOMES 2 PLAYER
                net_send("","message",e.name .. " /float")
                net_send("","message","Game mode changed to: Float training.")
                clients_queue()
            end
        end
        if e.type == 'net:message' and string.lower(e.value) == "/line" then
            if g2.state == "lobby" then
                GAME.galcon.gamemode = "Line"
                GAME.galcon.global.SOLO_MODE = true
                net_send("","message",e.name .. " /line")
                net_send("","message","Game mode changed to: Line.")
                clients_queue()
            end
        end
        if e.type == 'net:message' and string.lower(e.value) == "/race" then
            if g2.state == "lobby" then
                GAME.galcon.gamemode = "Race"
                GAME.galcon.global.SOLO_MODE = false
                net_send("","message",e.name .. " /race")
                net_send("","message","Game mode changed to: Race.")
                clients_queue()
            end
        end
        if e.type == 'net:message' and string.lower(e.value) == "/help" then
            net_send(e.uid,"message","(Server -> "..e.name..") List of commands: /start, /play, /queue, /away, /surrender, /who, /me, /hex, /color, /tournament, /matchup, /elo")
            net_send(e.uid,"message","(Server -> "..e.name..") Game modes: /classic, /stages, /frenzy, /grid, /float, /line, /race")
            if GAME.galcon.gamemode == "Grid" then
                net_send(e.uid,"message","(Server -> "..e.name..") Settings: /standard, /donut, /hexagon")
            end
            if e.uid == g2.uid then
                net_send(e.uid,"message","(Server -> "..e.name..") List of admin only commands: /abort, /awayall, /reset, /admin, /unadmin")
            end
        end
        if e.type == 'net:message' and string.lower(e.value) == "/solo" then
            net_send("","message",e.name .. " /solo")
            if(GAME.galcon.global.SOLO_MODE) then
                net_send("", "message", "Solo mode off!")
                GAME.galcon.global.SOLO_MODE = false
            else
                net_send("", "message", "Solo mode on!")
                GAME.galcon.global.SOLO_MODE = true
            end
            resetLobbyHtml()
        end
        if e.type == 'net:message' and string.lower(e.value) == "/mapstyle mix" then
            net_send("","message",e.name .. " /mapstyle mix")
            GAME.galcon.global.MAP_STYLE = "mix"
            resetLobbyHtml()
        end
        if e.type == 'net:message' and string.lower(e.value) == "/mapstyle classic" then
            net_send("","message",e.name .. " /mapstyle classic")
            GAME.galcon.global.MAP_STYLE = 0
            resetLobbyHtml()
        end
        if e.type == 'net:message' and string.lower(e.value) == "/mapstyle philbuff" then
            net_send("","message",e.name .. " /mapstyle philbuff")
            GAME.galcon.global.MAP_STYLE = 1
            resetLobbyHtml()
        end
        if e.type == 'net:message' and string.lower(e.value) == "/mapstyle 12p" then
            net_send("","message",e.name .. " /mapstyle 12p")
            GAME.galcon.global.MAP_STYLE = 2
            resetLobbyHtml()
        end
        if e.type == 'net:message' and string.lower(e.value) == "/mapstyle saandbuff" then
            net_send("","message",e.name .. " /mapstyle saandbuff")
            GAME.galcon.global.MAP_STYLE = 3
            resetLobbyHtml()
        end
        if e.type == 'net:message' and string.lower(e.value) == "/mapstyle wonk" then
            net_send("","message",e.name .. " /mapstyle wonk")
            GAME.galcon.global.MAP_STYLE = 4
            resetLobbyHtml()
        end
        if e.type == 'net:message' and string.lower(e.value) == "/set" then
            GAME.galcon.setmode = true
            local to = string.sub(e.value,6)
            GAME.galcon.setto = to
            net_send(e.uid,"message","set active")
        end
        if e.type == 'net:message' and string.lower(string.sub(e.value,1,3)) == "/me" then
            local message = string.sub(e.value,5)
            net_send("","message",e.name.." "..message)
        end
        if e.type == 'net:message' and string.lower(string.sub(e.value,1,11)) == "/tournament" then
            if not GAME.galcon.tournament then
                GAME.galcon.tournament = true
                net_send('', "message", "Tournament mode is active!")
            else
                GAME.galcon.tournament = false
                net_send('', "message", "Tournament mode is deactivated.")
            end
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
                    net_send("","message",g2.name.." /start")
                else
                    net_send("","message",e.name.." /start")
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
        if e.type == 'onclick' and e.value == '/play' then
            if e.status == "away" then
                e.status = "queue"
                clients_queue()
                net_send("","message",e.name .. " is /queue")
            end
            if e.name == nil then
                for i,v in pairs(GAME.clients) do
                    if g2.uid == v.uid then
                        if v.status == "away" then
                            v.status = "queue"
                            clients_queue()
                            net_send("","message",v.name .. " is /queue")

                        end
                    end
                end
            end
        end
        if e.type == 'onclick' and e.value == '/away' then
            if e.status == "play" or e.status == "queue" then
                e.status = "away"
                clients_queue()
                net_send("","message",e.name .. " is /away")
            end
            if e.name == nil then
                for i,v in pairs(GAME.clients) do
                    if g2.uid == v.uid then
                        if v.status == "play" or v.status == "queue" then
                            v.status = "away"
                            clients_queue()
                            net_send("","message",v.name .. " is /away")
                        end
                    end
                end
            end
        end
		if e.type == 'onclick' and e.value == '/lobby' then
            --net_send("", "message", "<debug> onclick for lobby")
			resetLobbyHtml(g2)
		end
		if e.type == 'onclick' and e.value == '/mode' then
            --net_send("", "message", "<debug> onclick for mode")
			modeTab(g2)
		end
		if e.type == 'onclick' and e.value == '/leaderboard' then
            --net_send("", "message", "<debug> onclick for leaderboard")
			loadScoreboard(g2)
		end
		if e.type == 'onclick' and e.value == '/settings' then
            --net_send("", "message", "<debug> onclick for settings")
			settingsTab(g2)
		end
        if e.type == 'onclick' and e.value == '/wardrobe' then
            net_send("", "message", "Wardrobe coming soon!")
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
    if GAME.galcon.global.SEED_DATA.CUSTOMISED then
        seed = GAME.galcon.global.SEED_DATA.SEED
        if GAME.galcon.global.SEED_DATA.KEEP_SEED == false then
            GAME.galcon.global.SEED_DATA.CUSTOMISED = false
        end
    end
    GAME.galcon.global.SEED_DATA.PREV_SEED = (seed % 1616606700)
    math.randomseed(seed)
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
    
    
    local users = {}
    G.users = users

    for uid,client in pairs(GAME.clients) do
        if client.status == "play" then
            local p = g2.new_user(client.name,client.color)
            users[#users+1] = p
            p.user_uid = client.uid
            if GAME.galcon.gamemode == "Race" then
                p.planet_crash = 2
            end
            client.live = 0
        end
    end

    local sw = OPTS.sw -- ELIM RATIO 560x360 -- Saand ratio 520x360
    local sh = OPTS.sh 

    local pad = 0
    if GAME.galcon.gamemode == "Stages" then
        g2.view_set(0, 0, sw, sh)
        local planets = {}

        local home_production, home_ships = 100, 100
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
        
        local numMapStyles = 5
        --local mapStyle = 3 -- MIX: getMapStyle(numMapStyles) // Classic: 0 // PhilBuff: 1 // 12p: 2 // Saandbuff: 3 // wonk: 4
        local mapStyle = -1
        if(GAME.galcon.global.MAP_STYLE == "mix") then
            mapStyle = getMapStyle(numMapStyles)            
        else
            mapStyle = GAME.galcon.global.MAP_STYLE
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
        g2.view_set(0, 0, sw, sh)

        local planets = {}

        local home_production, home_ships = 100, 100
        local home_r = prodToRadius(home_production)
        
        if mapStyle == 4 then
	    home_production = math.floor(math.random(1, 100))
	    home_ships = math.floor(math.random(1, 100))
	    home_r = prodToRadius(home_production)
	end

        local a = math.random(0,360)
        for i,user in pairs(users) do
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

        for i=1, OPTS.neutrals/2 do
            local prod = math.random(30,100)
            local radius = prodToRadius(prod)
            local x = math.random(radius, sw - radius)
            local y = math.random(radius, sh - radius)
            local cost = 0
            if mapStyle == 0 then
                cost = math.floor(math.random(0,30))
            elseif mapStyle == 1 then
                cost = math.floor(math.random(prod / 20, prod / 1.50))--math.floor(math.random(prod / 10, prod / 1.75))
            elseif mapStyle == 2 then
                cost = math.floor(math.random(0,20))
            elseif mapStyle == 3 then
           	if prod >= 30 and prod < 51 then
			cost = math.floor(math.random(5, 10))
		elseif prod >= 51 and prod < 76 then
			cost = math.floor(math.random(11, 30))
		elseif prod >= 76 and prod < 90 then
			cost = math.floor(math.random(30, 45))
		elseif prod >= 90 then
			cost = math.floor(math.random(45, 60))
		end
            elseif mapStyle == 4 then
            	local costRatio = math.floor(home_ships * .5)
            	cost = math.floor(math.random(0, costRatio))
            	prod = math.floor(math.random(1, 100))
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

            g2.new_planet(o, x, y, prod, cost)
            g2.new_planet(o, sw - x, sh - y, prod, cost)

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

    if GAME.galcon.gamemode == "Grid" then
        OPTS.sw = sw
        OPTS.sh = sh
        
        sw = sw/1.25
        sh = sh/1.25

        local planets = {}
        for i=0, math.sqrt(OPTS.neutrals)-1 do
            for j=0, math.sqrt(OPTS.neutrals)-1 do
            local x, y
            local neutrals_production = 30
            local neutrals_cost = 5

            x = sh/(OPTS.neutrals-1)*i*(math.sqrt(OPTS.neutrals)+1)
            y = sh/(OPTS.neutrals-1)*j*(math.sqrt(OPTS.neutrals)+1)

            local planet = g2.new_planet(o, x, y, neutrals_production, neutrals_cost);
            
            table.insert(planets, planet)
            end
        end

        local home = math.random(1, #planets)
        while home == (#planets+1)/2 do
            home = math.random(1, #planets)
        end
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
                g2.new_planet(users[1], position_x, position_y, 80, 100);
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
                    g2.new_planet(users[2], position_x, position_y, 80, 100);
                end
                
            end
            
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
                    g2.new_planet(users[n], position_x, position_y, 80, 100);
                end
            end
            if #users == 2 then
                if i == #planets then
                    local position_x = v.position_x
                    local position_y = v.position_y
                    v:destroy()
                    g2.new_planet(users[inverseN], position_x, position_y, 80, 100);
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
    net_send('',"message","Map seed: "..(seed % 1616606700) )
    g2.net_send("","sound","sfx-start");
    local r = g2.search("planet")
end

function count_production()
    local r = {}
    local items = g2.search("planet -neutral")
    for _i,o in ipairs(items) do
        if g2.item(o:owner().n).title_value ~= "neutral" then 
            local team = o:owner():team()
            r[team] = (r[team] or 0) + o.ships_production
        end
    end
    return r
end

function most_production()
    local r = count_production()
    local best_o = nil
    local best_v = 0
    for o,v in pairs(r) do
        if v > best_v then
            best_v = v
            best_o = o
        end
    end
    return best_o
end

function find_enemy(uid)
    for n, e in pairs(g2.search("user")) do
        -- user_neutral is not strictly necessary
        if e.user_uid ~= uid and not e.user_neutral and e.title_value ~= "neutral" then
            return e
        end
    end
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

function galcon_stop(res,time)
    if res == true then
        local winner = most_production()
        --print("winner uid: "..winner.user_uid)
        if winner ~= nil then
            if GAME.galcon.gamemode ~= "Race" then
                net_send("","message",winner.title_value.." conquered the galaxy")
            else
                net_send("","message",winner.title_value.." finished in "..GAME.galcon.finishTime.." seconds")
            end

            for j, u in pairs(GAME.galcon.scorecard) do
                if winner.user_uid == j then
                    if GAME.galcon.global.stupidSettings.silverMode and (winner.title_value == "silvershad0w" or winner.title_value == "HostAphid") then
                        u = u + 15
                    else
                        u = u + 1
                    end
                    GAME.galcon.scorecard[j] = u
                end
            end
            local loser = find_enemy(winner.user_uid)
            if loser ~= nil and loser.user_uid ~= nil then
                elo.update_elo(string.lower(winner.title_value), string.lower(loser.title_value), true)
                elo.save_ratings()
            end
           
            --print("loser uid: ".. loser.user_uid)
            if GAME.galcon.tournament == true and loser ~= nil then
                requeueLoser(loser.user_uid)
            end
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
    -- if getNumNonNeutralUsers() <= 1 and total == 0 then
    --     if GAME.modules.galcon.timeout > 3 then
    --         --galcon_stop(false,GAME.modules.galcon.timeout)
    --         check_for_match_end()
    --     end
    -- end
    -- if getNumNonNeutralUsers() > 1 and total <= 1 then
    --     if GAME.modules.galcon.timeout > 3 then
    --         --galcon_stop(true,GAME.modules.galcon.timeout)
    --         check_for_match_end()
    --     end
    -- end
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

function galcon_surrender(uid)
    local G = GAME.galcon

    local user = find_user(uid)
    if user == nil then return end
    for n,e in pairs(g2.search("planet owner:"..user)) do
        e:planet_chown(G.neutral)
    end
end

function galcon_init()
    GAME.modules.galcon = GAME.modules.galcon or {}
    GAME.galcon = GAME.galcon or {}
    local obj = GAME.modules.galcon
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
    end
    function obj:loop(t)
        galcon_classic_loop()
        self.time = self.time + t
        self.timeout = self.timeout + t
        if GAME.galcon.gamemode == "Float" then
            update_score(self.time)
            displayTimer(self.time)
        end
        if GAME.galcon.gamemode == "Float" then 
            if self.floatSpawn == false then
                if #GAME.galcon.users >= 1 then 
                    GAME.galcon.float.float_fleet = g2.new_fleet(GAME.galcon.users[1], 25, GAME.galcon.float.v[math.random(1, #GAME.galcon.float.v)],GAME.galcon.float.r[math.random(1, #GAME.galcon.float.r)])
                end
                self.floatSpawn = true
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
                net_send("","message",e.name.." /surrender")
                galcon_surrender(e.uid)
            else 
                net_send("","message",g2.name.." /surrender")
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
function clients_leave(e, rageQuit)
    if e.uid ~= g2.uid then
        net_send(e.uid,"state","quit")
    end
    if rageQuit then
        net_send("","message",e.name .. " rage quit!")
    end
    if GAME.clients[e.uid] ~= nil then
        if GAME.clients[e.uid].status == "play" and numWithStatus("play") == 1 and g2.state ~= "lobby" then
            GAME.engine:next(GAME.modules.lobby)
        end
        GAME.clients[e.uid].status = "away"
        clients_queue()
        GAME.clients[e.uid] = nil
        keywords_removeKeyword(e.name)
        play_sound("sfx-leave")
        clients_queue()
    end
end
function update_score(time)
    GAME.galcon.float.score = math.floor(GAME.galcon.float.score1 * GAME.galcon.float.score2 +0.5)
    
    if GAME.galcon.float.reinforceplanet.ships_value > GAME.galcon.float.reinforceplanet_cost then 
        GAME.galcon.float.reinforceplanet_cost = GAME.galcon.float.reinforceplanet_cost + 1
        GAME.galcon.float.score1 = GAME.galcon.float.reinforceplanet_cost
    end

    for i=1, #GAME.galcon.float.r do
        if GAME.galcon.float.r[i].ships_value < 1 then --cheated with shift spam
            GAME.galcon.float.score2 = GAME.galcon.float.score2 + 0.001
        end
    end
    if GAME.galcon.float.score ~= 0 then 
        g2.status = "Time: ".. math.floor(time).."              ".."Score: "..GAME.galcon.float.score
        g2.net_send("","status",g2.status)
    end
end
function displayTimer(time)
    if time ~= 0 then
        g2.status = "Time: ".. math.floor(time).."              ".."Score: "..GAME.galcon.float.score
        g2.net_send("","status",g2.status)
    end
end
function print_scoreTime(time)
    net_send("","message","Time survived: "..math.floor(math.floor(time+0.5)).." seconds")
    net_send("","message","Score: "..GAME.galcon.float.score.." points")
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
            g2_api_call("register",json.encode({title= GAME.galcon.global.TITLE .. " - "..playersPlay..'/'..playersLimit,port=GAME.data.port}))
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
function admins_init()
    makeAdmin("esparano")
    makeAdmin("saand")
    makeAdmin("tycho2")
    makeAdmin("saand.-")
    makeAdmin("binah.")
	makeAdmin("vivideraphid")
	makeAdmin("sukuna")
	makeAdmin("galaxy227")
	makeAdmin("silvershad0w")
	makeAdmin("reclamation-")
	makeAdmin("master_yoda_")
	makeAdmin("hurrinado334")
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