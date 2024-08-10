function handleNetMessage(e)
    if (e.type == 'net:message' and string.lower(e.value) == '/play') or (e.type == "net:message" and string.lower(e.value) == "/queue") then
        if GAME.clients[e.uid].status == "away" then
            GAME.clients[e.uid].status = "queue"
            clients_queue(e)
            net_send("","message",e.name .. " is /queue")
        end
    end
    if e.type == 'net:message' and string.lower(e.value) == "/gg" then
        if GAME.clients[e.uid].status == "play" then
            net_send("","message",e.name .. " GG's!")
            g2.net_send("","sound","sfx-gg")
        else
            net_send(e.uid, "message", "Only active players can gg")
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
            clients_queue(e)
            net_send("","message",e.name .. " is /away")
        end
    end
    -- can break a lot of things DONT USE
    if e.type == "net:message" and string.sub(e.value,1,11) == "/maxplayers" then
        local maxPlayers = tonumber(string.sub(e.value,13))
        GAME.galcon.global.MAX_PLAYERS = maxPlayers
        clients_queue(e)
        net_send('', "message", "Max players set to "..GAME.galcon.global.MAX_PLAYERS)
    end
    if e.type == 'net:message' and string.lower(e.value) == '/who' then
        local msg = ""
        for _,c in pairs(GAME.clients) do
            msg = msg .. c.name .. ", "
        end
        net_send(e.uid,"message","/who: "..msg)
    end
    if e.type =='net:message' and string.lower(string.sub(e.value,1,6)) == "/timer" then
        GAME.galcon.global.TIMER_LENGTH = string.sub(e.value, 8, string.len(e.value)) * 60
        resetLobbyHtml()
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
                if GAME.clients[e.uid].coins >= 1 or GAME.galcon.global.CONFIGS.saandCoins.enableSaandCoins == false then
                    GAME.clients[e.uid].color = color
                    GAME.clients[e.uid].colorData = color
                    editPlayerData("color", e.uid, color)
                    if GAME.galcon.global.CONFIGS.saandCoins.enableSaandCoins then
                        GAME.clients[e.uid].coins = GAME.clients[e.uid].coins - 1
                        editPlayerData("coin-u", e.uid, -1)
                    end
                    net_send(e.uid,'message','(Server -> '..e.name..') HEX-color changed to: '..color)
                    resetLobbyHtml()
                else
                    net_send(e.uid, "message", "Not enough SaandCoins!")
                end
            elseif color == "000000" then
                net_send(e.uid,'message','(Server -> '..e.name..') Error, color too dark.')
            end
            --print(dump(GAME.clients[e.uid]))
        end
    end
    if e.type == 'net:message' and string.lower(string.sub(e.value,1,7)) == "/title " then
        net_send("","message",e.name .. " " ..e.value)
        if GAME.galcon.global.stupidSettings.saandmode and GAME.clients[e.uid].title == "Saand Minion" and string.lower(e.name) ~= "binah." then
            net_send("","message", "You cannot change this title without being freed of the FATHER.")
        else
            local newTitle = string.sub(e.value, 8, string.len(e.value))
            local maxLen = 20
            if string.len(newTitle) > maxLen then
                net_send("","message", "Title too long, max "..maxLen.." chars")
            else 
                if censorCheck(newTitle, e.uid) == false then
                    if GAME.clients[e.uid].coins >= 5 or GAME.galcon.global.CONFIGS.saandCoins.enableSaandCoins == false then
                        GAME.clients[e.uid].title = newTitle
                        editPlayerData("title", e.uid, newTitle)
                        if GAME.galcon.global.CONFIGS.saandCoins.enableSaandCoins then
                            GAME.clients[e.uid].coins = GAME.clients[e.uid].coins - 5
                            editPlayerData("coin-u", e.uid, -5)
                        end
                    else
                        net_send(e.uid, "message", "Not enough SaandCoins!")
                    end
                else
                    if GAME.galcon.global.CONFIGS.saandCoins.enableSaandCoins then
                        GAME.clients[e.uid].coins = GAME.clients[e.uid].coins - 5
                        editPlayerData("coin-u", e.uid, -5)
                        net_send(e.uid, "message", "Keeping your coin anyways ;)")
                    end
                end
            end
            resetLobbyHtml()
        end           
    end
    if e.type == 'net:message' and string.lower(string.sub(e.value,1,9)) == "/setship " then
        local ship = string.lower(string.sub(e.value,10,string.len(e.value)))
        local hasShip = has_value(GAME.clients[e.uid].ownedShips, ship) 
        if GAME.clients[e.uid].coins >= 15 or hasShip or GAME.galcon.global.CONFIGS.saandCoins.enableSaandCoins == false then
            net_send(e.uid, "message", "Your ship is now " .. ship)
            GAME.clients[e.uid].ship = ship
            editPlayerData("ship", e.uid, ship)
            if hasShip == false then
                GAME.clients[e.uid].ownedShips[#GAME.clients[e.uid].ownedShips+1] = ship
                editPlayerData("ownedShips", e.uid, ship)
                if GAME.galcon.global.CONFIGS.saandCoins.enableSaandCoins then
                    GAME.clients[e.uid].coins = GAME.clients[e.uid].coins - 15
                    editPlayerData("coin-u", e.uid, -15)
                end
            end
        else
            net_send(e.uid, "message", "Not enough SaandCoins!")
        end
    end
    if e.type == 'net:message' and string.lower(string.sub(e.value,1,9)) == "/setskin " then
        local skin = string.lower(string.sub(e.value,10,string.len(e.value)))
        local hasSkin = has_value(GAME.clients[e.uid].ownedSkins, skin)
        if GAME.clients[e.uid].coins >= 30 or hasSkin or GAME.galcon.global.CONFIGS.saandCoins.enableSaandCoins == false then
            net_send(e.uid, "message", "Your skin is now " .. skin)
            GAME.clients[e.uid].skin = skin
            editPlayerData("skin", e.uid, skin)
            if hasSkin == false then
                GAME.clients[e.uid].ownedSkins[#GAME.clients[e.uid].ownedSkins+1] = skin
                editPlayerData("ownedSkins", e.uid, skin)
                if GAME.galcon.global.CONFIGS.saandCoins.enableSaandCoins then
                    GAME.clients[e.uid].coins = GAME.clients[e.uid].coins - 30
                    editPlayerData("coin-u", e.uid, -30) 
                end
            end
        else
            net_send(e.uid, "message", "Not enough SaandCoins!") 
        end
    end
    if e.type == 'net:message' and string.lower(string.sub(e.value,1,9)) == "/setname " then
        local name = string.sub(e.value,10,string.len(e.value))
        if GAME.clients[e.uid].coins >= 50 or GAME.galcon.global.CONFIGS.saandCoins.enableSaandCoins == false then
            if string.len(name) > 12 then
                net_send(e.uid, "message", "Name cannot be more than 12 characters.")
            elseif string.len(name) == 0 then
                net_send(e.uid, "message", "Name be at least 1 character.")
            else
                local valid = false
                valid = checkNoSpecialChars(name)
                if valid then
                    if censorCheck(name, e.uid) then
                        if GAME.galcon.global.CONFIGS.saandCoins.enableSaandCoins then
                            GAME.clients[e.uid].coins = GAME.clients[e.uid].coins - 50
                            editPlayerData("coin-u", e.uid, -50)
                            net_send(e.uid, "message", "Keeping your coin anyways ;)")
                        end
                    else
                        net_send(e.uid, "message", "Your name is now " .. name)
                        GAME.clients[e.uid].name = name
                        editPlayerData("name", e.uid, name)
                        resetLobbyHtml()
                        if GAME.galcon.global.CONFIGS.saandCoins.enableSaandCoins then
                            GAME.clients[e.uid].coins = GAME.clients[e.uid].coins - 50
                            editPlayerData("coin", e.uid, name)
                        end
                    end
                else
                    net_send(e.uid, "message", "Names cannot contain spaces or special characters.")
                end
            end
        else
            net_send(e.uid, "message", "Not enough SaandCoins!") 
        end
    end
    if e.type == 'net:message' and string.lower(e.value) == "/buycoins" then
        net_send("", "message", e.name.. " tried to buy their way to glory!")
        wardrobeCoinsSuccess(e)
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
    if e.type == 'net:message' and string.lower(e.value) == "/silver" and GAME.galcon.global.CONFIGS.enableTrollModes then
        if GAME.clients[e.uid].officialName == "silvershad0w" or GAME.clients[e.uid].officialName == "HostAphid" then
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
    if e.type == 'net:message' and string.lower(e.value) == "/ggwp" and GAME.galcon.global.CONFIGS.enableTrollModes then
        net_send("", "message", e.name .. " /ggwp")
        if GAME.clients[e.uid].officialName == "hurrinado334" or GAME.clients[e.uid].officialName == "HostAphid" then
            net_send("", "message", "You are fragile enough...")
            if GAME.galcon.global.stupidSettings.yodaFilter then
                GAME.galcon.global.stupidSettings.yodaFilter = false
                net_send("", "message", "Yoda filter deactivated!")
            else
                GAME.galcon.global.stupidSettings.yodaFilter = true
                net_send("", "message", "Yoda filter active!")
            end
        else
            if string.lower(e.officialName) == "master_yoda_" then
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
    if e.type == 'net:message' and string.lower(e.value) == "/father" and GAME.galcon.global.CONFIGS.enableTrollModes then
        net_send("", "message", e.name .. " /father")
        if string.lower(GAME.clients[e.uid].officialName) == "binah." or GAME.clients[e.uid].officialName == "HostAphid" then
            if GAME.galcon.global.stupidSettings.saandmode then
                net_send("", "message", "Father Elim shall have mercy for now...")
                GAME.galcon.global.stupidSettings.saandmode = false
            else
                net_send("", "message", "Hail Father Elim Saand!")
                GAME.galcon.global.stupidSettings.saandmode = true
            end
        else
            net_send("", "message", "SACRILEGE! YOU ARE NOT FATHER SAAND!")
            GAME.clients[e.uid].title = "SHAME"
            resetLobbyHtml()
        end
    end
    if e.type == 'net:message' and string.lower(e.value) == "/breadmode" and GAME.galcon.global.CONFIGS.enableTrollModes then
        net_send("", "message", e.name.." /breadmode")
        if string.lower(GAME.clients[e.uid].officialName) == "bread" or GAME.clients[e.uid].officialName == "HostAphid" then
            if GAME.galcon.global.stupidSettings.breadmode then
                net_send("", "message", "Breadmode off!")
                GAME.galcon.global.stupidSettings.breadmode = false
            else
                net_send("", "message", "Breadmode on!")
                GAME.galcon.global.stupidSettings.breadmode = true
                GAME.clients[e.uid].color = "0x9898fe" --4c4c7e old dark
                playerData.setPlayerColor(e.uid,GAME.clients[e.uid].color)
                playerData.saveData()
                resetLobbyHtml()
            end
        else
            net_send("", "message", "You are not bread.")
        end
    end
    if e.type == 'net:message' and string.lower(e.value) == "/rechameleon" and GAME.galcon.global.CONFIGS.enableTrollModes then
        net_send("", "message", e.name.." /rechameleon")
        if string.lower(GAME.clients[e.uid].officialName) == "reclamation-" or GAME.clients[e.uid].officialName == "HostAphid" then
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
        wardrobe(e)
    end
    if e.type == 'net:message' and string.lower(e.value) == '/wardrobe skins' then
        wardrobeSkins(e)
    end
    if e.type == 'net:message' and string.lower(e.value) == '/wardrobe colors' then
        wardrobeColors(e)
    end
    if e.type == 'net:message' and string.lower(e.value) == '/wardrobe ships' then
        wardrobeShips(e)
    end
    if e.type == 'net:message' and string.lower(e.value) == '/wardrobe name' then
        wardrobeName(e)
    end
    if e.type == 'net:message' and string.lower(e.value) == '/wardrobe title' then
        wardrobeTitle(e)
    end
    if e.type == 'net:message' and string.lower(e.value) == '/wardrobe coins' then
        wardrobeCoins(e)
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
                    GAME.galcon.global.SEED_DATA.SEED_STRING = extract
                    seed = toNumberExtended(extract)
                end
            else
                GAME.galcon.global.SEED_DATA.SEED_STRING = extract
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
        net_send("", "message", e.name .. " /replayseed")
        GAME.galcon.global.SEED_DATA.SEED = GAME.galcon.global.SEED_DATA.PREV_SEED
        GAME.galcon.global.SEED_DATA.SEED_STRING = GAME.galcon.global.SEED_DATA.PREV_SEED_STRING
        GAME.galcon.global.SEED_DATA.CUSTOMISED = true
        resetLobbyHtml()
    end
    if e.type == 'net:message' and string.lower(e.value) == "/keepseed" then
        net_send("", "message", e.name .. " /keepseed")
        if GAME.galcon.global.SEED_DATA.KEEP_SEED then
            net_send("", "message", "keepseed off!")
            GAME.galcon.global.SEED_DATA.KEEP_SEED = false
        else
            net_send("", "message", "keepseed on!")
            GAME.galcon.global.SEED_DATA.KEEP_SEED = true
            if GAME.galcon.global.SEED_DATA.CUSTOMISED == false then
                GAME.galcon.global.SEED_DATA.CUSTOMISED = true
                GAME.galcon.global.SEED_DATA.SEED = GAME.galcon.global.SEED_DATA.PREV_SEED
                GAME.galcon.global.SEED_DATA.SEED_STRING = GAME.galcon.global.SEED_DATA.PREV_SEED_STRING
            end
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
            GAME.galcon.gametype = "Standard" or "Donut" or "Hexagon" or "Mix"
            net_send("","message",e.name .. " /grid")
            net_send("","message","Game mode changed to: Grid.")
            clients_queue()
        end
    end
    if e.type == 'net:message' and string.lower(e.value) == "/gridstyle mix" then
        if g2.state == "lobby" then
            GAME.galcon.gametype = "Mix"
            net_send("","message",e.name .. " /gridstyle mix")
            clients_queue()
        end
    end
    if e.type == 'net:message' and string.lower(e.value) == "/gridstyle standard" then
        if g2.state == "lobby" then
            GAME.galcon.gametype = "Standard"
            net_send("","message",e.name .. " /gridstyle standard")
            clients_queue()
        end
    end
    if e.type == 'net:message' and string.lower(e.value) == "/gridstyle donut" then
        if g2.state == "lobby" then
            GAME.galcon.gametype = "Donut"
            net_send("","message",e.name .. " /gridstyle donut")
            clients_queue()
        end
    end
    if e.type == 'net:message' and string.lower(e.value) == "/gridstyle hexagon" then
        if g2.state == "lobby" then
            GAME.galcon.gametype = "Hexagon"
            net_send("","message",e.name .. " /gridstyle hexagon")
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
    if e.type == 'net:message' and string.lower(string.sub(e.value, 1, 16)) == "/togglesaandbuff" then
        local version = string.lower(string.sub(e.value, 18))
        version = tonumber(version)
        if(version ~= nil) then
            GAME.galcon.global.SAANDBUFF_DATA.VERSIONS_ENABLED[version] = not GAME.galcon.global.SAANDBUFF_DATA.VERSIONS_ENABLED[version]
        end
        settingsTab(e)
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
    if e.type == 'net:message' and string.lower(e.value) == "/winnerstays" then
        if not GAME.galcon.global.WINNER_STAYS then
            GAME.galcon.global.WINNER_STAYS = true
            net_send('', "message", "Winner stays mode is active!")
        else
            GAME.galcon.global.WINNER_STAYS = false
            net_send('', "message", "Winner stays mode is deactivated.")
        end
    end
end

function handleOnclick(e)
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
    if e.type == 'onclick' and string.lower(e.value) == "/gg" then
       if GAME.clients[e.uid or g2.uid].status == "play" then
            net_send("","message",(e.name or g2.name) .. " GG's!")
            g2.net_send("","sound","sfx-gg")
        else
            net_send((e.uid or g2.uid), "message", "Only active players can gg")
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
        wardrobe(g2)
    end
    if e.type == 'onclick' and e.value == '/wardrobe colors' then
        wardrobeColors(g2)
    end
    if e.type == 'onclick' and e.value == '/wardrobe skins' then
        wardrobeSkins(g2)
    end
    if e.type == 'onclick' and e.value == '/wardrobe ships' then
        wardrobeShips(g2)
    end
    
end