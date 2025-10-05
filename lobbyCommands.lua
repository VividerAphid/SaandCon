function handleNetMessage(e)
    if (e.type == 'net:message' and string.lower(e.value) == '/play') or (e.type == "net:message" and string.lower(e.value) == "/queue") then
        if GAME.clients[e.uid].status == "away" then
            GAME.clients[e.uid].status = "queue"
            clients_queue(e)
            net_send("","message",GAME.clients[e.uid].displayName .. " is /queue")
        end
    end
    if e.type == 'net:message' and string.lower(string.sub(e.value,1,5)) == '/play' then
        local target_name = string.sub(e.value, 7)
        for _,v in pairs(GAME.clients)do
            if v.name:lower()==target_name:lower()then
                if(tonumber(v.uid) < 0 or isAdmin(e.name)) then
                    if v.status == "away" then
                        v.status = "queue"
                        clients_queue(v)
                        net_send("","message",GAME.clients[v.uid].displayName .. " is /queue")
                    end
                else
                    net_send(e.uid, "message", "Must be admin to /play that player")
                end
            end
        end 
    end
    if e.type == 'net:message' and e.value =='/toggleplay' then
        --print("toggle!")
        playStateCheck(e)
    end
    if e.type == 'net:message' and string.lower(string.sub(e.value,1,11)) == '/toggleplay' then
        local target_player = string.sub(e.value, 13)
        for _,v in pairs(GAME.clients)do
            if v.name:lower()==target_player:lower()then
                if(tonumber(v.uid) < 0 or isAdmin(e.uid)) then
                    playStateCheck(v)
                end
            end
        end 
    end
    if e.type == 'net:message' and (string.lower(e.value) == "/gg" or string.lower(e.value) == "/ggwp") then
        if GAME.clients[e.uid].status == "play" then
            net_send("","message",GAME.clients[e.uid].displayName .. " GG's!")
            g2.net_send("","sound","sfx-gg")
        else
            net_send(e.uid, "message", "Only active players can gg")
        end
    end
    if e.type =='net:message' and string.lower(string.sub(e.value,1,10)) == "/givecoins" then
        local chunks = {} --break into substrings, [2] for name [3] for coin amount   
        for chunk in e.value:gmatch("%S+") do table.insert(chunks, chunk) end
        local target_name = chunks[2] or ""
        local coins = tonumber(chunks[3]) or 0
        for _,v in pairs(GAME.clients) do
            if v.name:lower()==target_name:lower()then
                if GAME.galcon.global.CONFIGS.saandCoins.enableSaandCoins then
                    if GAME.clients[e.uid].coins >= coins and coins > -1 then
                        net_send(v.uid, "message", GAME.clients[e.uid].displayName.." gives you "..coins.." "..GAME.galcon.global.CONFIGS.saandCoins.currency_name.."!")
                        net_send(e.uid, "message", "You gave "..GAME.clients[v.uid].displayName.." "..coins.." "..GAME.galcon.global.CONFIGS.saandCoins.currency_name.."!")
                        if tonumber(v.uid) > 0 then
                            GAME.clients[e.uid].coins = GAME.clients[e.uid].coins - coins
                            editPlayerData("coin-u", e.uid, coins*-1)
                            GAME.clients[v.uid].coins = GAME.clients[v.uid].coins + coins
                            editPlayerData("coin-u", v.uid, coins)
                        else
                            net_send("", "message", "Bots cannot receive tips. Their wages compensate them well enough.")
                            sendBotMessage(v.uid, "Thank you for the coins "..GAME.clients[e.uid].displayName..", but I cannot accept them.")
                        end
                    elseif coins < 0 then
                        net_send(e.uid, "message", "Good try. You think I didn't think of that? ;)")
                    else
                        net_send(e.uid, "message", "Not enough "..GAME.galcon.global.CONFIGS.saandCoins.currency_name.."!")
                        net_send("", "message", GAME.clients[e.uid].displayName.." showers "..GAME.clients[v.uid].displayName.." in "..coins.." fake "..GAME.galcon.global.CONFIGS.saandCoins.currency_name.."!")
                    end
                else
                    net_send("", "message", GAME.clients[e.uid].displayName.." showers "..GAME.clients[v.uid].displayName.." in "..coins.." fake "..GAME.galcon.global.CONFIGS.saandCoins.currency_name.."!")
                end
            end
        end
    end
    if e.type =='net:message' and string.lower(string.sub(e.value,1,11)) == "/awardcoins" then
        if(e.uid == g2.uid) then --hack to check if host is making the command, dont let anyone else use it
            local chunks = {} --break into substrings, [2] for name [3] for coin amount   
            for chunk in e.value:gmatch("%S+") do table.insert(chunks, chunk) end
            local target_name = chunks[2]
            local coins = tonumber(chunks[3])
            for _,v in pairs(GAME.clients) do
                if v.name:lower()==target_name:lower()then
                    net_send("", "message", GAME.clients[v.uid].displayName.." was awarded "..coins.." "..GAME.galcon.global.CONFIGS.saandCoins.currency_name.."!")
                    local amount = coins
                    if(coins < 0 and ((GAME.clients[v.uid].coins - coins) <= 0)) then
                        amount = 0
                    end
                    GAME.clients[v.uid].coins = GAME.clients[v.uid].coins + amount
                    editPlayerData("coin-u", v.uid, amount)
                    net_send(v.uid, "message", "You now have "..GAME.clients[v.uid].coins.." "..GAME.galcon.global.CONFIGS.saandCoins.currency_name.."!")
                end
            end
        else
            net_send(e.uid, "message", "You are not authorized to award coins.")
        end
    end
    if e.type == 'net:message' and string.lower(e.value) == "/addbot" then
        if(GAME.galcon.global.BOT_COUNT < GAME.galcon.global.MAX_BOT_COUNT) then
            local bot_name = getNewBotName()
            local bot = 'classic'
            local bot_type = "Classic"
            local bot_uid = getNewBotUID()
            --print(bot_uid)
            GAME.modules.clients:event({uid=bot_uid,name=bot_name,bot=bot,type="net:join"})
            GAME.clients[bot_uid].title = "BOT-"..bot_type
            GAME.galcon.global.BOTS[bot_uid] = {name=bot_name, bot=bot}
            resetLobbyHtml()
            GAME.galcon.global.BOT_COUNT = GAME.galcon.global.BOT_COUNT + 1
        else
            net_send("", "message", "Max bot count is "..GAME.galcon.global.MAX_BOT_COUNT)
        end
    end
    if e.type == 'net:message' and string.lower(string.sub(e.value,1,8)) == "/kickbot" then
        local target_name = string.sub(e.value, 10)
        for _,v in pairs(GAME.galcon.global.BOTS)do
            if v.name:lower()==target_name:lower()then
                GAME.galcon.global.BOTS[_]=nil
                GAME.modules.clients:event({uid=_,name=target_name,type="net:leave"})
            end
        end 
    end
    if e.type == 'net:message' and string.lower(e.value) == "/kickallbots" then
        for _,v in pairs(GAME.galcon.global.BOTS) do
            local bname = GAME.galcon.global.BOTS[_].name
            GAME.galcon.global.BOTS[_]=nil
			GAME.modules.clients:event({uid=_,name=bname,type="net:leave"})
            resetLobbyHtml()
        end
        GAME.galcon.global.BOT_COUNT = 0
    end
    if e.type == 'net:message' and string.lower(string.sub(e.value,1,5)) == "/kick" then
        if(isAdmin(e.name)) then
            local target_name = string.sub(e.value, 7)
            for _,v in pairs(GAME.clients)do
                if v.name:lower()==target_name:lower()then
                    if(tonumber(v.uid) < 0) then
                        GAME.galcon.global.BOTS[_]=nil
                        GAME.modules.clients:event({uid=_,name=target_name,type="net:leave"})
                    else
                        net_send("", "message", target_name.." was kicked.")
                        clients_leave(_, false)
                    end
                end
            end 
        else
            net_send(e.uid,"message", "Not authorised to kick players.")
        end
        
    end
    if (e.type == 'net:message' and string.lower(e.value) == '/version') then
        net_send(e.uid, "message", "Version is "..GAME.galcon.global.CONFIGS.version)
    end
    if (e.type == 'net:message' and string.lower(e.value) == '/lobby') then
        --net_send("", "message", "<debug> net:message for lobby")
        resetLobbyHtml(e)
    end
    if (e.type == 'net:message' and string.lower(e.value) == '/settings') then
        --net_send("", "message", "<debug> net:message for mode")
        modeTab(e)
    end
    if (e.type == 'net:message' and string.lower((string.sub(e.value,1,8))) == '/profile') then
        local uid = string.sub(e.value, 10)
        if uid == "self" then
            loadProfile(e, e.uid)
        else
            loadProfile(e, uid)
        end
    end
    if (e.type == 'net:message' and string.lower(e.value) == '/leaderboard') then
        --net_send("", "message", "<debug> net:message for settings")
        loadScoreboard(e)
    end
    if e.type == 'net:message' and string.lower(string.sub(e.value,1,5)) == '/away' then
        local target_name = string.sub(e.value, 7)
        for _,v in pairs(GAME.clients)do
            if v.name:lower()==target_name:lower()then
                if(tonumber(v.uid) < 0 or isAdmin(e.name)) then
                    if v.status == "play" or v.status == "queue" then
                        v.status = "away"
                        clients_queue(v)
                        net_send("","message",GAME.clients[v.uid].displayName .. " is /away")
                    end
                else
                    net_send(e.uid, "message", "Must be admin to /away that player")
                end
            end
        end 
    end
    if e.type == 'net:message' and string.lower(e.value) == '/away' then
        if GAME.clients[e.uid].status == "play" or GAME.clients[e.uid].status == "queue" then
            GAME.clients[e.uid].status = "away"
            clients_queue(e)
            net_send("","message",GAME.clients[e.uid].displayName .. " is /away")
        end
        --playStateCheck(e)
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
        local timer_value = tonumber(string.sub(e.value, 8, string.len(e.value)))
        if(timer_value ~= "" and type(timer_value) == "number") then
            GAME.galcon.global.TIMER_LENGTH = timer_value * 60
            net_send("", "message", "Timer changed to " .. timer_value * 60)
        else
            net_send(e.uid, "message", "Timer value not recognised")
        end
        
        --resetLobbyHtml()
    end
    if e.type =='net:message' and string.lower(string.sub(e.value,1,6)) == "/homes" then
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Settings changes are disabled during ranked mode!")
            return
        end
        GAME.galcon.global.HOME_COUNT = string.sub(e.value, 8, string.len(e.value))
        net_send("", "message", "Home count changed to " .. string.sub(e.value, 8, string.len(e.value)))
        --resetLobbyHtml()
    end
    if e.type =='net:message' and string.lower(string.sub(e.value,1,9)) == "/homeprod" then
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Settings changes are disabled during ranked mode!")
            return
        end
        if(GAME.galcon.gamemode == "Grid") then
            print("set grid prod")
            GAME.galcon.global.GRID.HOME_PROD = string.sub(e.value, 11, string.len(e.value))
        else
            print("set home prod")
            GAME.galcon.global.HOME_PROD = string.sub(e.value, 11, string.len(e.value))
        end
        net_send("", "message", "Home prod changed to " .. string.sub(e.value, 11, string.len(e.value)))
        --resetLobbyHtml()
    end
    if e.type =='net:message' and string.lower(string.sub(e.value,1,11)) == "/startships" then
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Settings changes are disabled during ranked mode!")
            return
        end
        net_send("", "message", "Starting ships changed to " .. string.sub(e.value, 13, string.len(e.value)))
        GAME.galcon.global.STARTING_SHIPS = string.sub(e.value, 13, string.len(e.value))
        --resetLobbyHtml()
    end
    if e.type =='net:message' and string.lower(string.sub(e.value,1,13)) == "/gridneutcost" then
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Settings changes are disabled during ranked mode!")
            return
        end
        net_send("", "message", "Grid neut cost changed to " .. string.sub(e.value, 15, string.len(e.value)))
        GAME.galcon.global.GRID.NEUT_COST = string.sub(e.value, 15, string.len(e.value))
        --resetLobbyHtml()
    end
    if e.type =='net:message' and string.lower(string.sub(e.value,1,13)) == "/gridneutprod" then
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Settings changes are disabled during ranked mode!")
            return
        end
        net_send("", "message", "Grid neut prod changed to " .. string.sub(e.value, 15, string.len(e.value)))
        GAME.galcon.global.GRID.NEUT_PROD = string.sub(e.value, 15, string.len(e.value))
        --resetLobbyHtml()
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
                    net_send(e.uid, "message", "Not enough "..GAME.galcon.global.CONFIGS.saandCoins.currency_name.."!")
                end
            elseif color == "000000" then
                net_send(e.uid,'message','(Server -> '..e.name..') Error, color too dark.')
            end
            --print(dump(GAME.clients[e.uid]))
        end
    end
    if e.type == 'net:message' and string.lower(string.sub(e.value,1,7)) == "/title " then
        net_send("","message",GAME.clients[e.uid].displayName .. " " ..e.value)
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
                        net_send(e.uid, "message", "Not enough "..GAME.galcon.global.CONFIGS.saandCoins.currency_name.."!")
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
    if e.type == 'net:message' and string.lower(string.sub(e.value,1,7)) == "/quote " then
        net_send("","message",GAME.clients[e.uid].displayName .. " " ..e.value)
        local newQuote = string.sub(e.value, 8, string.len(e.value))
        local maxLen = 100
        if string.len(newQuote) > maxLen then
            net_send("","message", "Quote too long, max "..maxLen.." chars")
        else 
            if censorCheck(newQuote, e.uid) == false then
                if GAME.clients[e.uid].coins >= 5 or GAME.galcon.global.CONFIGS.saandCoins.enableSaandCoins == false then
                    GAME.clients[e.uid].quote = newQuote
                    editPlayerData("quote", e.uid, newQuote)
                    if GAME.galcon.global.CONFIGS.saandCoins.enableSaandCoins then
                        GAME.clients[e.uid].coins = GAME.clients[e.uid].coins - 10
                        editPlayerData("coin-u", e.uid, -10)
                    end
                else
                    net_send(e.uid, "message", "Not enough "..GAME.galcon.global.CONFIGS.saandCoins.currency_name.."!")
                end
            else
                if GAME.galcon.global.CONFIGS.saandCoins.enableSaandCoins then
                    GAME.clients[e.uid].coins = GAME.clients[e.uid].coins - 10
                    editPlayerData("coin-u", e.uid, -10)
                    net_send(e.uid, "message", "Keeping your coin anyways ;)")
                end
            end
        end
        resetLobbyHtml()          
    end
    if e.type == 'net:message' and string.lower(string.sub(e.value,1,9)) == "/setship " then
        local ship = string.lower(string.sub(e.value,10,string.len(e.value)))
        local hasShip = has_value(GAME.clients[e.uid].ownedShips, ship) 
        if GAME.clients[e.uid].coins >= 15 or hasShip or GAME.galcon.global.CONFIGS.saandCoins.enableSaandCoins == false then
            net_send(e.uid, "message", "Your ship is now " .. ship)
            GAME.clients[e.uid].ship = ship
            editPlayerData("ship", e.uid, ship)
            if hasShip == false then
                GAME.clients[e.uid].ownedShips[#GAME.clients[e.uid].ownedShips + 1] = ship
                editPlayerData("ownedships", e.uid, ship)
                print(#GAME.clients[e.uid].ownedShips)
                if GAME.galcon.global.CONFIGS.saandCoins.enableSaandCoins then
                    GAME.clients[e.uid].coins = GAME.clients[e.uid].coins - 15
                    editPlayerData("coin-u", e.uid, -15)
                end
            end
        else
            net_send(e.uid, "message", "Not enough "..GAME.galcon.global.CONFIGS.saandCoins.currency_name.."!")
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
                editPlayerData("ownedskins", e.uid, skin)
                if GAME.galcon.global.CONFIGS.saandCoins.enableSaandCoins then
                    GAME.clients[e.uid].coins = GAME.clients[e.uid].coins - 30
                    editPlayerData("coin-u", e.uid, -30) 
                end
            end
        else
            net_send(e.uid, "message", "Not enough "..GAME.galcon.global.CONFIGS.saandCoins.currency_name.."!") 
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
                        GAME.clients[e.uid].displayName = name
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
            net_send(e.uid, "message", "Not enough "..GAME.galcon.global.CONFIGS.saandCoins.currency_name.."!") 
        end
    end
    if e.type == 'net:message' and string.lower(e.value) == "/prestige" then
        local player = playerData.getUserData(e.uid)
        if(player.level == GAME.galcon.global.CONFIGS.maxPlayerLevel) then
            handlePrestige(e.uid)
        else
            net_send(e.uid, "message", "You are not high enough level to be reborn!")
        end
    end
    if e.type == 'net:message' and string.lower(e.value) == "/rollcolor" then
        local color = rollRandColor()
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
            net_send(e.uid, "message", "Not enough "..GAME.galcon.global.CONFIGS.saandCoins.currency_name.."!")
        end
    end
    if e.type == 'net:message' and string.lower(e.value) == "/buycoins" then
        net_send("", "message", GAME.clients[e.uid].displayName.. " tried to buy their way to glory!")
        wardrobeCoinsSuccess(e)
    end
    if e.type == 'net:message' and string.lower(string.sub(e.value,1,6)) == "/admin" then
        if isAdmin(e.name) then
            local adminName = string.sub(e.value,8)
            local worked = makeAdmin(adminName)
            if worked then 
                net_send("","message",GAME.clients[e.uid].displayName .. " /admin " .. adminName)
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
                net_send("","message",GAME.clients[e.uid].displayName .. " /unadmin " .. adminName)
                resetLobbyHtml()
            else
                net_send(e.uid,'message','(Server -> '..GAME.clients[e.uid].displayName..') Error, failed to unadmin '.. adminName .. '.')
            end
        end
    end
    if e.type == 'net:message' and string.lower(e.value) == "/reset" then
        net_send("","message",GAME.clients[e.uid].displayName .. " /reset")
        if GAME.clients[e.uid].status == "play" or isAdmin(e.name) then
            for i, e in pairs(GAME.galcon.scorecard) do
                GAME.galcon.scorecard[i] = 0
            end
            net_send("","message", "Scores reset.")
            clients_queue()
        else
            net_send(e.uid, "message", "Only active players can use /reset")
        end
    end
    if e.type == 'net:message' and string.lower(e.value) == "/silver" and GAME.galcon.global.CONFIGS.enableTrollModes then
        if GAME.clients[e.uid].name == "silvershad0w" or GAME.clients[e.uid].name == "HostAphid" then
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
    if e.type == 'net:message' and string.lower(e.value) == "/yodamute" and GAME.galcon.global.CONFIGS.enableTrollModes then
        net_send("", "message", GAME.clients[e.uid].displayName .. " /yodamute")
        if GAME.clients[e.uid].name == "hurrinado334" or GAME.clients[e.uid].name == "HostAphid" then
            net_send("", "message", "You are fragile enough...")
            if GAME.galcon.global.stupidSettings.yodaFilter then
                GAME.galcon.global.stupidSettings.yodaFilter = false
                net_send("", "message", "Yoda filter deactivated!")
            else
                GAME.galcon.global.stupidSettings.yodaFilter = true
                net_send("", "message", "Yoda filter active!")
            end
        else
            if string.lower(GAME.clients[e.uid].name) == "master_yoda_" then
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
        net_send("", "message", GAME.clients[e.uid].displayName .. " /father")
        if string.lower(GAME.clients[e.uid].name) == "binah." or GAME.clients[e.uid].name == "HostAphid" then
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
        net_send("", "message", GAME.clients[e.uid].displayName.." /breadmode")
        if string.lower(GAME.clients[e.uid].name) == "bread" or GAME.clients[e.uid].name == "HostAphid" then
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
        net_send("", "message", GAME.clients[e.uid].displayName.." /rechameleon")
        if string.lower(GAME.clients[e.uid].name) == "reclamation-" or GAME.clients[e.uid].name == "HostAphid" then
        end
    end
    if e.type == 'net:message' and string.lower(e.value) == "/mins" then
        net_send("", "message", GAME.clients[e.uid].displayName .. " /mins")
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
        --GAME.clients[e.uid] = nil
        keywords_removeKeyword(e.name)
        keywords_removeKeyword(GAME.clients[e.uid].displayName)
        keywords_refreshKeywords()
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
    if e.type == 'net:message' and string.lower(e.value) == '/wardrobe quote' then
        wardrobeQuote(e)
    end
    if e.type == 'net:message' and string.lower(e.value) == '/wardrobe coins' then
        wardrobeCoins(e)
    end
    if e.type == 'net:message' and string.lower(e.value) == "/classic" then
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Settings changes are disabled during ranked mode!")
            return
        end
        if g2.state == "lobby" then
            GAME.galcon.gamemode = "Classic"
            GAME.galcon.global.SOLO_MODE = false
            net_send("","message",GAME.clients[e.uid].displayName .. " /classic")
            net_send("","message","Game mode changed to: Classic.")
            clients_queue()
        end
    end
    if e.type == 'net:message' and string.find(string.lower(e.value), "/seed") ~= nil then
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Settings changes are disabled during ranked mode!")
            return
        end
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
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Settings changes are disabled during ranked mode!")
            return
        end
        net_send("", "message", GAME.clients[e.uid].displayName .. " /replayseed")
        GAME.galcon.global.SEED_DATA.SEED = GAME.galcon.global.SEED_DATA.PREV_SEED
        GAME.galcon.global.SEED_DATA.SEED_STRING = GAME.galcon.global.SEED_DATA.PREV_SEED_STRING
        GAME.galcon.global.SEED_DATA.CUSTOMISED = true
        resetLobbyHtml()
    end
    if e.type == 'net:message' and string.lower(e.value) == "/keepseed" then
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Settings changes are disabled during ranked mode!")
            return
        end
        net_send("", "message", GAME.clients[e.uid].displayName .. " /keepseed")
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
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Settings changes are disabled during ranked mode!")
            return
        end
        if g2.state == "lobby" then
            GAME.galcon.gamemode = "Stages"
            GAME.galcon.global.SOLO_MODE = false
            net_send("","message",GAME.clients[e.uid].displayName .. " /stages")
            net_send("","message","Game mode changed to: Stages.")
            clients_queue()
        end
    end
    if e.type == 'net:message' and string.lower(e.value) == "/frenzy" then
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Settings changes are disabled during ranked mode!")
            return
        end
        if g2.state == "lobby" then
            GAME.galcon.gamemode = "Frenzy"
            GAME.galcon.global.SOLO_MODE = false
            net_send("","message",GAME.clients[e.uid].displayName .. " /frenzy")
            net_send("","message","Game mode changed to: Frenzy.")
            clients_queue()
        end
    end
    if e.type == 'net:message' and string.lower(e.value) == "/grid" then
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Settings changes are disabled during ranked mode!")
            return
        end
        if g2.state == "lobby" then
            GAME.galcon.gamemode = "Grid"
            GAME.galcon.global.SOLO_MODE = false
            GAME.galcon.gametype = "Standard" or "Donut" or "Hexagon" or "Mix"
            net_send("","message",GAME.clients[e.uid].displayName .. " /grid")
            net_send("","message","Game mode changed to: Grid.")
            clients_queue()
        end
    end
    if e.type == 'net:message' and string.lower(e.value) == "/gridstyle mix" then
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Settings changes are disabled during ranked mode!")
            return
        end
        if g2.state == "lobby" then
            GAME.galcon.gametype = "Mix"
            net_send("","message",GAME.clients[e.uid].displayName .. " /gridstyle mix")
            clients_queue()
        end
    end
    if e.type == 'net:message' and string.lower(e.value) == "/gridstyle standard" then
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Settings changes are disabled during ranked mode!")
            return
        end
        if g2.state == "lobby" then
            GAME.galcon.gametype = "Standard"
            net_send("","message",GAME.clients[e.uid].displayName .. " /gridstyle standard")
            clients_queue()
        end
    end
    if e.type == 'net:message' and string.lower(e.value) == "/gridstyle donut" then
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Settings changes are disabled during ranked mode!")
            return
        end
        if g2.state == "lobby" then
            GAME.galcon.gametype = "Donut"
            net_send("","message",GAME.clients[e.uid].displayName .. " /gridstyle donut")
            clients_queue()
        end
    end
    if e.type == 'net:message' and string.lower(e.value) == "/gridstyle hexagon" then
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Settings changes are disabled during ranked mode!")
            return
        end
        if g2.state == "lobby" then
            GAME.galcon.gametype = "Hexagon"
            net_send("","message",GAME.clients[e.uid].displayName .. " /gridstyle hexagon")
            clients_queue()
        end
    end
    if e.type == 'net:message' and string.lower(e.value) == "/float" then
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Settings changes are disabled during ranked mode!")
            return
        end
        if g2.state == "lobby" then
            GAME.galcon.gamemode = "Float"
            GAME.galcon.global.SOLO_MODE = true --DONT FORGET TO CHANGE THIS LATER IF FLOAT BECOMES 2 PLAYER
            net_send("","message",GAME.clients[e.uid].displayName .. " /float")
            net_send("","message","Game mode changed to: Float training.")
            clients_queue()
        end
    end
    if e.type == 'net:message' and string.lower(e.value) == "/line" then
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Settings changes are disabled during ranked mode!")
            return
        end
        if g2.state == "lobby" then
            GAME.galcon.gamemode = "Line"
            GAME.galcon.global.SOLO_MODE = true
            net_send("","message",GAME.clients[e.uid].displayName .. " /line")
            net_send("","message","Game mode changed to: Line.")
            clients_queue()
        end
    end
    if e.type == 'net:message' and string.lower(e.value) == "/race" then
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Settings changes are disabled during ranked mode!")
            return
        end
        if g2.state == "lobby" then
            GAME.galcon.gamemode = "Race"
            GAME.galcon.global.SOLO_MODE = false
            net_send("","message",GAME.clients[e.uid].displayName .. " /race")
            net_send("","message","Game mode changed to: Race.")
            clients_queue()
        end
    end
    if e.type == 'net:message' and string.lower(e.value) == "/expand 1" then
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Settings changes are disabled during ranked mode!")
            return
        end
        if g2.state == "lobby" then
            GAME.galcon.gamemode = "Classic"
            GAME.galcon.global.SOLO_MODE = false
            GAME.galcon.global.MAP_STYLE = 5
            net_send("","message",GAME.clients[e.uid].displayName .. " /expand 1")
            net_send("","message","Game mode changed to: Expand.")
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
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Settings changes are disabled during ranked mode!")
            return
        end
        net_send("","message",GAME.clients[e.uid].displayName .. " /solo")
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
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Settings changes are disabled during ranked mode!")
            return
        end
        net_send("","message",GAME.clients[e.uid].displayName .. " /mapstyle mix")
        GAME.galcon.global.MAP_STYLE = "mix"
        resetLobbyHtml()
    end
    if e.type == 'net:message' and string.lower(e.value) == "/mapstyle classic" then
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Settings changes are disabled during ranked mode!")
            return
        end
        net_send("","message",GAME.clients[e.uid].displayName .. " /mapstyle classic")
        GAME.galcon.global.MAP_STYLE = 0
        resetLobbyHtml()
    end
    if e.type == 'net:message' and string.lower(e.value) == "/mapstyle philbuff" then
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Settings changes are disabled during ranked mode!")
            return
        end
        net_send("","message",GAME.clients[e.uid].displayName .. " /mapstyle philbuff")
        GAME.galcon.global.MAP_STYLE = 1
        resetLobbyHtml()
    end
    if e.type == 'net:message' and string.lower(e.value) == "/mapstyle 12p" then
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Settings changes are disabled during ranked mode!")
            return
        end
        net_send("","message",GAME.clients[e.uid].displayName .. " /mapstyle 12p")
        GAME.galcon.global.MAP_STYLE = 2
        resetLobbyHtml()
    end
    if e.type == 'net:message' and string.lower(e.value) == "/mapstyle saandbuff" then
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Settings changes are disabled during ranked mode!")
            return
        end
        net_send("","message",GAME.clients[e.uid].displayName .. " /mapstyle saandbuff")
        GAME.galcon.global.MAP_STYLE = 3
        resetLobbyHtml()
    end
    if e.type == 'net:message' and string.lower(e.value) == "/mapstyle wonk" then
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Settings changes are disabled during ranked mode!")
            return
        end
        net_send("","message",GAME.clients[e.uid].displayName .. " /mapstyle wonk")
        GAME.galcon.global.MAP_STYLE = 4
        resetLobbyHtml()
    end
    if e.type == 'net:message' and string.lower(e.value) == "/randradius" then
        if(not GAME.galcon.global.RANKED) then
            GAME.galcon.global.CONFIGS.randRadiusMode = not GAME.galcon.global.CONFIGS.randRadiusMode
            net_send("","message",GAME.clients[e.uid].displayName .. " /randradius")
            if(GAME.galcon.global.CONFIGS.randRadiusMode) then
                net_send("","message","Random radius enabled!")
            else
                net_send("","message","Random radius disabled!")

            end
        else
            net_send("", "message", "Settings changes are disabled during ranked mode!")
        end
        
    end
    if e.type == 'net:message' and string.lower(string.sub(e.value, 1, 16)) == "/togglesaandbuff" then
        if(not GAME.galcon.global.RANKED) then
            local version = string.lower(string.sub(e.value, 18))
            version = tonumber(version)
            if(version ~= nil) then
                GAME.galcon.global.SAANDBUFF_DATA.VERSIONS_ENABLED[version] = not GAME.galcon.global.SAANDBUFF_DATA.VERSIONS_ENABLED[version]
            end
            modeTab(e)
        else
            net_send("", "message", "Settings changes are disabled during ranked mode!")
        end  
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
    if e.type == 'net:message' and string.lower(e.value) == "/defaults" then
        net_send("","message",GAME.clients[e.uid].displayName .. " /defaults")
        net_send("","message","Lobby reset to default settings.")
        GAME.galcon.gamemode = "Classic"
        GAME.galcon.tournament = false
        GAME.galcon.setmode = false
        GAME.galcon.global.WINNER_STAYS = GAME.galcon.global.CONFIGS.defaults.WINNER_STAYS
        GAME.galcon.global.MAX_PLAYERS = GAME.galcon.global.CONFIGS.defaults.MAX_PLAYERS
        GAME.galcon.global.SOLO_MODE = false
        GAME.galcon.global.TEAMS_MODE = GAME.galcon.global.CONFIGS.defaults.TEAMS_MODE
        GAME.galcon.global.MAP_STYLE = GAME.galcon.global.CONFIGS.defaults.MAP_STYLE
        GAME.galcon.global.SAANDBUFF_DATA = GAME.galcon.global.CONFIGS.defaults.SAANDBUFF_DATA
        GAME.galcon.global.TIMER_LENGTH = GAME.galcon.global.CONFIGS.defaults.TIMER_LENGTH
        GAME.galcon.global.STARTING_SHIPS = GAME.galcon.global.CONFIGS.defaults.STARTING_SHIPS
        GAME.galcon.global.HOME_COUNT = GAME.galcon.global.CONFIGS.defaults.HOME_COUNT
        GAME.galcon.global.GRID.NEUT_COST = GAME.galcon.global.CONFIGS.defaults.GRID.NEUT_COST
        GAME.galcon.global.GRID.NEUT_PROD = GAME.galcon.global.CONFIGS.defaults.GRID.NEUT_PROD
        GAME.galcon.global.GRID.HOME_PROD = GAME.galcon.global.CONFIGS.defaults.GRID.HOME_PROD
        GAME.galcon.global.GRID.START_SHIPS = GAME.galcon.global.CONFIGS.defaults.GRID.START_SHIPS
        GAME.galcon.global.SEED_DATA = GAME.galcon.global.CONFIGS.defaults.SEED_DATA
        GAME.galcon.global.stupidSettings = GAME.galcon.global.CONFIGS.defaults.stupidSettings
        GAME.galcon.global.PLAYLIST = GAME.galcon.global.CONFIGS.defaults.PLAYLIST
        GAME.galcon.global.PLAYLIST_INDEX = GAME.galcon.global.CONFIGS.defaults.PLAYLIST_INDEX
        GAME.galcon.global.PLAYLIST_NAME = GAME.galcon.global.CONFIGS.defaults.PLAYLIST_NAME
        GAME.galcon.global.PLAYLIST_STYLE = GAME.galcon.global.CONFIGS.defaults.PLAYLIST_STYLE
        resetLobbyHtml()
    end
    if e.type == 'net:message' and string.lower(e.value) == "/countdown" then
        if isAdmin(e.name) then
            if GAME.galcon.global.CONFIGS.startTimerLength == 3 then
                net_send("","message","Countdown timer toggled to 5 seconds!")
                GAME.galcon.global.CONFIGS.startTimerLength = 5
            else
                net_send("","message","Countdown timer toggled to 3 seconds!")
                GAME.galcon.global.CONFIGS.startTimerLength = 3
            end
        end
    end
    if e.type == 'net:message' and string.lower(e.value) == "/toggleplaylist" then
        if(not GAME.galcon.global.RANKED) then
           GAME.galcon.global.PLAYLIST_MODE = not GAME.galcon.global.PLAYLIST_MODE
            if(GAME.galcon.global.PLAYLIST_MODE) then
                local playLists = loadPlayLists()
                GAME.galcon.global.PLAYLIST = playLists["ElimV2"]
                net_send("", "message", "Playlist mode started!")
                -- handlePlayListModeChange()
                resetLobbyHtml()
            else
                net_send("", "message", "Playlist mode stopped!")
                GAME.galcon.global.PLAYLIST = {}
                GAME.galcon.global.PLAYLIST_INDEX = 0
                GAME.galcon.global.PLAYLIST_STYLE = GAME.galcon.global.CONFIGS.defaults.PLAYLIST_STYLE
            end
        else
            net_send("", "message", "Settings changes are disabled during ranked mode!")
        end
    end
    if e.type == 'net:message' and string.lower(e.value) == "/toggleranked" then
        GAME.galcon.global.RANKED = not GAME.galcon.global.RANKED
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Ranked mode on!")
            GAME.galcon.global.MAX_PLAYERS = GAME.galcon.global.CONFIGS.defaults.MAX_PLAYERS
            GAME.galcon.global.TEAMS_MODE = GAME.galcon.global.CONFIGS.defaults.TEAMS_MODE
            GAME.galcon.global.PLAYLIST = loadPlayLists()['ElimV2']
            GAME.galcon.global.PLAYLIST_NAME = "ElimV2"
            GAME.galcon.global.PLAYLIST_MODE = true
            GAME.galcon.global.PLAYLIST_INDEX = 0
            resetLobbyHtml()
        else
            net_send("", "message", "Ranked mode off!")
            GAME.galcon.global.PLAYLIST = {}
            GAME.galcon.global.PLAYLIST_NAME = "ElimV2"
            GAME.galcon.global.PLAYLIST_MODE = false
            GAME.galcon.global.PLAYLIST_INDEX = 0
            resetLobbyHtml()
        end
    end
    if e.type == 'net:message' and string.lower(e.value) == "/toggle2v2" then
        if(GAME.galcon.global.RANKED) then
            net_send("", "message", "Settings changes are disabled during ranked mode!")
            return
        end
        GAME.galcon.global.TEAMS_MODE = not GAME.galcon.global.TEAMS_MODE
        if(GAME.galcon.global.TEAMS_MODE) then
            net_send("", "message", "Teams mode enabled!")
            GAME.galcon.global.MAX_PLAYERS = 4
        else
            net_send("", "message", "Teams mode disabled!")
            GAME.galcon.global.MAX_PLAYERS = 2
        end
        resetLobbyHtml()
    end
end

function handleOnclick(e)
    if e.type == 'onclick' and e.value =='/toggleplay' then
        --print("toggle!")
        playStateCheck(e)
    end
    if e.type == 'onclick' and e.value == '/play' then
        playStateCheck(e)
    end
    if e.type == 'onclick' and string.lower(e.value) == "/gg" then
       if GAME.clients[e.uid or g2.uid].status == "play" then
            net_send("","message",(GAME.clients[e.uid].displayName or g2.displayName) .. " GG's!")
            g2.net_send("","sound","sfx-gg")
        else
            net_send((e.uid or g2.uid), "message", "Only active players can gg")
        end
    end
    if e.type == 'onclick' and e.value == '/away' then
        playStateCheck(e)
    end
    if e.type == 'onclick' and e.value == '/lobby' then
        --net_send("", "message", "<debug> onclick for lobby")
        resetLobbyHtml(g2)
    end
    if e.type == 'onclick' and e.value == '/settings' then
        --net_send("", "message", "<debug> onclick for mode")
        modeTab(g2)
    end
    if e.type == 'onclick' and e.value == '/profile self' then
        --net_send("", "message", "<debug> onclick for mode")
        loadProfile(g2, g2.uid)
    end
    if e.type == 'onclick' and e.value == '/leaderboard' then
        --net_send("", "message", "<debug> onclick for leaderboard")
        loadScoreboard(g2)
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

function playStateCheck(e)
    local uid = hostUidFix(e)
    if GAME.clients[uid].status == "away" then
        GAME.clients[uid].status = "queue"
        clients_queue()
        net_send("","message", GAME.clients[uid].displayName .. " is /queue")
    elseif GAME.clients[uid].status == "play" or GAME.clients[uid].status == "queue" then
        GAME.clients[uid].status = "away"
        clients_queue()
        net_send("","message",GAME.clients[uid].displayName .. " is /away")
        removeFromQueue(uid)
    end
end