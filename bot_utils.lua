local BOT_NAMES = {"Gamaray200000", "GoodSaand", "Nando", "Yaster_Moda_", "Quasont", "Minzzz", "SirSpamAlot", "Botzooka", "Spamageddon","MrMakeYouRQ",
"RageQuitter", "GriefBot232", "BlitzBot", "Elimatron", "SirDeletesU", "Purge.exe", "Sonic.exe", "Bladeon", "Vaeron", "Mildora", "Lickasaurous",
"DFWaffl3z", "DTFWaffl3z", "BiteDatThang", "TheAntiSuke", "Wave-999", "AphidButGood", "Pogleta", "Slivershad0w"}

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
    local winOptions = {"Close", "GG", "GG WP", "Almost", "Nice try"}
    local gloatOptions = {"IM WIN", "Not even close noob", "Noob", "Try being better", "Get gud", "LOL", "BOW", "You've been mounted"}
    local loseOptions = {"GG", "GG WP", "Nice", "Good one", "WP"}
    local saltOptions = {"Stinking mcs", "Kid was climbing on me again", "Kid climbed my phone", "Ping was above 10", "-_-", "Bruh",
                        "LIE ITEMS SHIPS", "FLY "..math.random(5, 10).." REAL ".. math.random(20, 50), "Stupid mid maps", "Noob", "LAG", 
                        "Don't make me learn PC and smack you silly"}
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

--bot imports
require("bot_classic")
require("bot_proto_waffle")

-- Return the number of ships "planet" will have "time" seconds from now
function future_ships(planet, time)
    local ships = planet.ships_value
    if planet.ships_production_enabled then
        ships = ships + prod_to_ships(planet.ships_production) * time
    end
    return ships
end

-- convert distance to time (assumes constant ship movement speed)
function dist_to_time(dist)
	return dist/40
end

-- convert time to distance (assumes constant ship movement speed)
function time_to_dist(time)
	return time*40
end

-- convert planet production to ships per second 
function prod_to_ships(prod)
    return prod / 50
end

-- convert ships per second to planet production
function ships_to_prod(ships)
    return ships * 50
end

-- try to send an amount of ships, return the amount sent
function send_exact(user, from, to, ships)
    if from.ships_value < ships then
        from:fleet_send(100, to)
        return from.ships_value
    end
    local perc = ships / from.ships_value * 100
    if perc > 100 then perc = 100 end
    from:fleet_send(perc, to)
    return ships
end

-- create a deep copy of the object, return the copy
function deep_copy(obj)
    local copy = {}
    if type(obj) ~= 'table' then return obj end
    for k,v in pairs(obj) do
        copy[k] = deep_copy(v)
    end
    return copy
end

-- find the best item described by "query" using a evaluation function "eval"
function find(query,eval)
    local res = g2.search(query)
    local best = nil; local value = nil
    for _i,item in pairs(res) do
        local _value = eval(item)
        if _value ~= nil and (value == nil or _value > value) then
            best = item
            value = _value
        end
    end
    return best
end