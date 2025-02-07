local BOT_NAMES = {"Gamaray200000", "GoodSaand", "Nando", "Yaster_Moda_", "Quasont", "Minzzz", "SirSpamAlot", "Botzooka", "Spamageddon","MrMakeYouRQ",
"RageQuitter", "GriefBot232", "BlitzBot", "Elimatron", "SirDeletesU", "Purge.exe", "Sonic.exe", "Bladeon", "Vaeron", "Mildora", "Lickasaurous",
"DFWaffl3z", "DTFWaffl3z", "BiteDatThang", "TheAntiSuke", "Wave-999", "AphidButGood", "Pogleta"}

function getNewBotName()
    local usePresetName = math.random(1,2)
    local pickedName = "Bot"
    if(usePresetName == 2) then
        local pick = math.random(1, #BOT_NAMES)
        pickedName = BOT_NAMES[pick]
    else
        local pick = math.random(1, 999)
        pickedName = pickedName .. pick
    end
    return pickedName
end

function getNewBotUID()
    GAME.galcon.global.BOT_UID = GAME.galcon.global.BOT_UID-1
    return GAME.galcon.global.BOT_UID
end

function getNewBotShip()
    return GAME.galcon.global.ships[math.random(1, #GAME.galcon.global.ships)]
end

function getNewBotSkin()
    return GAME.galcon.global.planets[math.random(1, #GAME.galcon.global.planets)]
end

function getBotGG(botuid, win)
    local winOptions = {"Close", "GG", "GG WP", "Almost"}
    local gloatOptions = {"IM WIN", "Not even close noob", "Noob", "Try being better", "Get gud", "LOL", "BOW"}
    local loseOptions = {"GG", "GG WP", "Nice", "Good one", "WP"}
    local saltOptions = {"Stinking mcs", "Kid was climbing on me again", "Kid climbed my phone", "Ping was above 10", "-_-", "Bruh",
                        "LIE ITEMS SHIPS", "FLY "..math.random(5, 10).." REAL ".. math.random(20, 50), "Stupid mid maps", "Noob"}
    local message = ""
    if(win) then
        if(math.random(1, 4) == 4) then
            message = gloatOptions[math.random(1, #gloatOptions)]
        else
            message = winOptions[math.random(1, #winOptions)]
        end
    else
        if(math.random(1, 4) == 4) then
            message = saltOptions[math.random(1, #saltOptions)]
        else
            message = loseOptions[math.random(1, #loseOptions)]
        end
    end
    sendBotMessage(botuid, message)
end

function sendBotMessage(uid, message)
    local bot = GAME.clients[uid]
    net_send("","chat",json.encode({uid=bot.uid,color=bot.color,value="<[BOT]"..bot.name.."> "..message}))
end